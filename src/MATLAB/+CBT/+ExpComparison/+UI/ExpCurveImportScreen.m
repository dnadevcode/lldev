classdef ExpCurveImportScreen < handle
    % EXPCURVEIMPORTSCREEN 
    
    properties (Constant)
        Version = [0, 0, 1];
        ExpCurvesDataPoolID = 'ExpCurves';
    end
    properties (Access = private)
        TabbedScreen
        ImportTabHandle
        ImportPanelHandle
        
        VerifyBeforeRemovals = true;
        Verbose = false;
    end
    properties (SetAccess = private)
        ExpCurveListManager
    end
    
    
    methods
        function [ecis] = ExpCurveImportScreen(ts)
            if nargin < 1
                figTitle = 'Experiment Curves';
                import Fancy.UI.FancyTabs.TabbedScreen;
                ts = TabbedScreen.make_tabbed_screen_in_new_fig(figTitle);
            end
            
            import CBT.ExpComparison.UI.ExpCurveImportScreen;
            import Fancy.AppMgr.AppDataPoolMgr;
            if not(AppDataPoolMgr.has_data_pool(ExpCurveImportScreen.ExpCurvesDataPoolID))
                AppDataPoolMgr.create_new_data_pool(ExpCurveImportScreen.ExpCurvesDataPoolID);
            end
            
            import CBT.ExpComparison.UI.ExpCurveImportScreen;
            tabTitle = 'Experiment Curves';
            deleteFcn = @(varargin) ecis.delete();
            [hPanelExpCurveImport, hTabExpCurveImport] = ExpCurveImportScreen.make_import_panel_in_new_tab(ts, tabTitle, deleteFcn);
            ts.select_tab(hTabExpCurveImport);
            ecis.TabbedScreen = ts;
            ecis.ImportTabHandle = hTabExpCurveImport;
            ecis.ImportPanelHandle = hPanelExpCurveImport;

            import Fancy.UI.FancyList.FancyListMgr;
            eclm = FancyListMgr();
            ecis.ExpCurveListManager = eclm;
            eclm.set_ui_parent(ecis.ImportPanelHandle);
            eclm.make_ui_items_listbox();
            
            ecis.sync_ui_list_data();
            
            import Fancy.UI.FancyList.FancyListMgr;
            import Fancy.UI.FancyList.FancyListMgrBtnSet;
            
            flmbs1 = FancyListMgrBtnSet();
            flmbs1.NUM_BUTTON_COLS = 2;
            flmbs1.add_button(FancyListMgr.make_select_all_button_template());
            flmbs1.add_button(FancyListMgr.make_deselect_all_button_template());
            
            flmbs2 = FancyListMgrBtnSet();
            flmbs2.NUM_BUTTON_COLS = 1;
            flmbs2.add_button(ExpCurveImportScreen.make_add_exp_curves_button_template(ecis));
            flmbs2.add_button(ExpCurveImportScreen.make_remove_exp_curves_button_template(ecis));
            
            eclm.add_button_sets(flmbs1, flmbs2);
        end
        
        function delete(ecis) % Clean up data super explicitly to reduce any memory leak risk
            if isvalid(ecis.ExpCurveListManager)
                delete(ecis.ExpCurveListManager);
            end
        end
        
        
        function [hasFilepaths] = hs_nt_seq_filepaths(ecis, ntSeqFilepathQueries)
            [~, ntSeqFilepaths] = ecis.get_nt_seq_filepaths();
            n = length(ntSeqFilepathQueries);
            hasFilepaths = false(n, 1);
            [~, idxQueries, ~] = intersect(ntSeqFilepathQueries, ntSeqFilepaths);
            hasFilepaths(idxQueries) = true;
        end
        
        function [ntSeqFilepathDisplayNames, ntSeqFilepaths] = get_nt_seq_filepaths(ecis)
            listItems = ecis.ExpCurveListManager.get_all_list_items();
            ntSeqFilepathDisplayNames = listItems(:, 1);
            ntSeqImportItemContexts = listItems(:, 2);
            ntSeqFilepaths = cellfun(...
                @(iic) iic.ImportSrcPath ,...
                ntSeqImportItemContexts, ...
                'UniformOutput', false);
        end
        
        function [] = add_exp_curve(ecis, experimentCurveName, experimentCurveStruct)
            ecis.add_exp_curves({experimentCurveName}, {experimentCurveStruct});
        end
        
        function [] = add_exp_curves(ecis, experimentCurveNames, experimentCurveStructs)
            experimentCurveNames = experimentCurveNames(:);
            dupeItemsMask = ecis.hs_nt_seq_filepaths(experimentCurveNames);
            newItemsMask = not(dupeItemsMask);
            
            import Fancy.AppMgr.ImportItemContext;
            import Fancy.AppMgr.AppDataPoolMgr;
            import CBT.ExpComparison.UI.ExpCurveImportScreen;
            if any(newItemsMask)
                AppDataPoolMgr.update_data_items(ExpCurveImportScreen.ExpCurvesDataPoolID, experimentCurveNames, experimentCurveStructs);
                ecis.sync_ui_list_data();
                if ecis.Verbose
                    fprintf('The following curves were added to the list:\n');
                    tableAdded = table(experimentCurveNames(:), 'VariableNames', {'Exp. Curves'});
                    disp(tableAdded);
                end
            end
            if ecis.Verbose && any(dupeItemsMask)
                dupeCurveNames = experimentCurveNames(dupeItemsMask);
                fprintf('The following curves were not added to the list since they were already present:\n');
                tableSkipped = table(dupeCurveNames(:), 'VariableNames', {'Exp. Curves'});
                disp(tableSkipped);
            end
        end
        
        function [] = sync_ui_list_data(ecis)
            eclm = ecis.ExpCurveListManager;
            
            import CBT.ExpComparison.UI.ExpCurveImportScreen;
            import Fancy.AppMgr.AppDataPoolMgr;
            [expCurves, expCurveDisplayNames] = AppDataPoolMgr.get_data_items(ExpCurveImportScreen.ExpCurvesDataPoolID);
            
            eclm.set_list_items(expCurveDisplayNames, expCurves); 
        end
        
        function [] = remove_exp_curve_filepaths(ecis, indicesForRemoval)
            eclm = ecis.ExpCurveListManager;
            itemsForRemoval = eclm.get_display_value_pair_list(indicesForRemoval);
            filepathsForRemoval = cellfun(...
                @(importItemContext) ...
                    importItemContext.ImportSrcPath, ...
                itemsForRemoval(:, 2), ...
                'UniformOutput', false);
            
            import CBT.ExpComparison.UI.ExpCurveImportScreen;
            import Fancy.AppMgr.AppDataPoolMgr;
            dataItemIDsToRemove = filepathsForRemoval;
            [~, ~] = AppDataPoolMgr.remove_data_items(ExpCurveImportScreen.ExpCurvesDataPoolID, dataItemIDsToRemove);
            
            ecis.sync_ui_list_data();
            
            % % Todo: consider unloading nt seqs not in the list
            % %  if the user confirms that it is ok and the nt seq
            % %  isn't otherwise referred to by other data/code
            % unloadSeqsMask = false(size(filepathsForRemoval));
            % filepathsForSeqsToUnload = filepathsForRemoval(unloadSeqsMask);
            % ExpCurveImportScreen.unload_exp_curve_objects(filepathsForSeqsToUnload);
        end
    end
    
    methods (Access = private)
        function continueRemoval = verify_removal(~, itemsForRemoval)
            numDeletionItems = size(itemsForRemoval, 1);
            if numDeletionItems == 0
                msgbox('No entries were selected for removal!', 'Removal Failure');
                return;
            end
            if numDeletionItems == 1
                question = 'Are you sure you wish to remove the selected entry?';
            else
                question = sprintf('Are you sure you wish to remove the %d selected entries?', numDeletionItems);
            end
            optConfirmRemoval = 'Yes';
            optAbortRemoval = 'No';
            optDefault = optAbortRemoval;
            choice = questdlg(question, 'Removal Confirmation', optConfirmRemoval, optAbortRemoval, optDefault);
            continueRemoval = strcmp(choice, optConfirmRemoval);
        end
    end
    
    methods(Static, Access = private)
        function [btnAddItems] = make_add_exp_curves_button_template(ecis)
            import Fancy.UI.FancyList.FancyListMgrBtn;

            function add_items_from_prompt()
                import CBT.TheoryComparison.Import.get_experiment_curves;
                [aborted, experimentCurveNames, experimentCurveStructs] = get_experiment_curves();
                if aborted
                    return;
                end

                ecis.add_exp_curves(experimentCurveNames, experimentCurveStructs)
            end
            buttonText = 'Add exp. curve(s)';
            callback = @(~, ~, flm) add_items_from_prompt();
            btnAddItems = FancyListMgrBtn(buttonText, callback);
        end
        
        function [btnRemoveItems] = make_remove_exp_curves_button_template(ecis)
            import Fancy.UI.FancyList.FancyListMgrBtn;
            function [] = try_remove_selected_items()
                eclm = ecis.ExpCurveListManager;
                indicesForRemoval = eclm.get_selected_indices();

                itemsForRemoval = eclm.get_display_value_pair_list(indicesForRemoval);

                verifyBeforeRemoval = ecis.VerifyBeforeRemovals;
                if verifyBeforeRemoval
                    continueRemoval = ecis.verify_removal(itemsForRemoval);

                    if not(continueRemoval)
                        return;
                    end
                end
                ecis.remove_exp_curve_filepaths(indicesForRemoval);
            end
            btnRemoveItems = FancyListMgrBtn('Remove exp. curve(s)', @(~, ~, flm) try_remove_selected_items());
        end
        
        function [hExpCurveImportPanel, hExpCurveImportTab] = make_import_panel_in_new_tab(ts, tabTitle, deleteFcn)
            
            [hExpCurveImportTab] = ts.create_tab(tabTitle, deleteFcn);
            hExpCurveImportPanel = uipanel(...
                'Parent', hExpCurveImportTab, ...
                'Position', [0, 0, 1, 1]);
        end
    end
end 