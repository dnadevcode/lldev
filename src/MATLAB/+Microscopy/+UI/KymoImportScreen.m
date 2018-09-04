classdef KymoImportScreen
    properties (Constant)
        Version = [0, 0, 1];
        KymoObjFilepathsDataPoolID = 'KymoObjFilepaths';
    end
    properties (Access = private)
        TabbedScreen
        ImportTabHandle
        ImportPanelHandle
    end
    properties (SetAccess = private)
        KymoFilepathListManager
    end
    methods
        function [kis] = KymoImportScreen(ts)
            if nargin < 1
                figTitle = 'Kymos';
                import Fancy.UI.FancyTabs.TabbedScreen;
                ts = TabbedScreen.make_tabbed_screen_in_new_fig(figTitle);
            end
            
            import Microscopy.UI.KymoImportScreen;
            tabTitle = 'Kymo Filepaths';
            deleteFcn = @(varargin) kis.delete();
            [hKymoImportPanel, hKymoImportTab] = KymoImportScreen.make_import_panel_in_new_tab(ts, tabTitle, deleteFcn);
            kis.TabbedScreen = ts;
            kis.ImportTabHandle = hKymoImportTab;
            kis.ImportPanelHandle = hKymoImportPanel;
            
            import Fancy.UI.FancyList.FancyListMgr;
            kflm = FancyListMgr();
            kis.KymoFilepathListManager = kflm;
            kflm.set_ui_parent(kis.ImportPanelHandle);
            kflm.make_ui_items_listbox();
            
            kis.sync_ui_list_data();
            
            import Fancy.UI.FancyList.FancyListMgr;
            import Fancy.UI.FancyList.FancyListMgrBtnSet;
            
            flmbs1 = FancyListMgrBtnSet();
            flmbs1.NUM_BUTTON_COLS = 2;
            flmbs1.add_button(FancyListMgr.make_select_all_button_template());
            flmbs1.add_button(FancyListMgr.make_deselect_all_button_template());
            flmbs1.add_button(KymoImportScreen.make_add_kymo_filepaths_button_template(kis));
            flmbs1.add_button(KymoImportScreen.make_remove_kymo_filepaths_button_template(kis));
            
            flmbs2 = FancyListMgrBtnSet();
            flmbs2.NUM_BUTTON_COLS = 1;
            flmbs2.add_button(KymoImportScreen.make_add_movie_kymos_button_template(kis));
            flmbs2.add_button(KymoImportScreen.make_load_kymo_button_template(kis));
            
            kflm.add_button_sets(flmbs1, flmbs2);
        end
        
        function delete(kis) % Clean up data super explicitly to reduce any memory leak risk
            if isvalid(kis.KymoFilepathListManager)
                delete(kis.KymoFilepathListManager);
            end
        end
        
        function [] = load_kymo_objects(kis, indicesForLoading)
            kflm = kis.KymoFilepathListManager;
            importItemContexts = kflm.get_display_value_pair_list(indicesForLoading);
            
            import Microscopy.KymoFactory;
            kymoFactory = KymoFactory.get_instance();
            
            import Microscopy.Import.import_grayscale_tiff_video;
            numFiles = size(importItemContexts, 1);
            for filepathIdx = 1:numFiles
                displayName = importItemContexts{filepathIdx, 1};
                fprintf('::> Loading kymo for %s...\n', displayName);
                importItemContext = importItemContexts{filepathIdx, 2};

                [failMsg, kymoObj] = kymoFactory.load_kymo_from_mat(importItemContext.ImportSrcPath);
                if any(failMsg)
                    fprintf(' Kymo load failure: %s\n', failMsg);
                    fprintf('<:: Failed loading kymo for %s\n', displayName);
                else
                    
                    %TODO: consider prompting to prevent
                    %  loading data that is already available
                    %  (since files/code may have changed we shouldn't
                    %   avoid reloading data automatically)
                    import Fancy.AppMgr.AppDataPoolMgr;
                    import Microscopy.UI.KymoImportScreen;
                    loadedKymoDataItemID = importItemContext.ImportSrcPath;
                    AppDataPoolMgr.update_data_item(KymoImportScreen.LoadedKymosDataPoolID, loadedKymoDataItemID, kymoObj);

                    fprintf('<:: Loaded kymo for %s\n', displayName);
                end
            end
            fprintf(': Completed load attempts for all %d selected kymos\n', numFiles);
        end
        
        
        
        function [hasFilepaths] = has_kymo_filepaths(kis, kymoFilepathQueries)
            [~, kymoFilepaths] = kis.get_movie_filepaths();
            n = length(kymoFilepathQueries);
            hasFilepaths = false(n, 1);
            [~, idxQueries, ~] = intersect(kymoFilepathQueries, kymoFilepaths);
            hasFilepaths(idxQueries) = true;
        end
        
        function [kymoFilepathDisplayNames, kymoFilepaths] = get_kymo_filepaths(kis)
            listItems = kis.KymoFilepathListManager.get_all_list_items();
            kymoFilepathDisplayNames = listItems(:, 1);
            kymoImportItemContexts = listItems(:, 2);
            kymoFilepaths = cellfun(...
                @(iic) iic.ImportSrcPath ,...
                kymoImportItemContexts, ...
                'UniformOutput', false);
        end
        
        function [] = add_kymo_filepath(kis, additionalKymoFilepath)
            kis.add_kymo_filepaths({additionalKymoFilepath});
        end
        
        function [] = add_kymo_filepaths(kis, additionalKymoFilepaths)
            additionalKymoFilepaths = additionalKymoFilepaths(:);
            dupeItemsMask = kis.has_kymo_filepaths(additionalKymoFilepaths);
            newItemsMask = not(dupeItemsMask);
            
            import Fancy.AppMgr.ImportItemContext;
            if any(newItemsMask)
                itemSelectionTime = clock();
                newItemFilepaths = additionalKymoFilepaths(newItemsMask);
                newImportItemContexts = cellfun(...
                    @(newItemFilepath) ...
                        ImportItemContext(newItemFilepath, itemSelectionTime), ...
                        newItemFilepaths, ...
                        'UniformOutput', false);
                % Note: ImportSrcPath property of importItemContexts
                %   should be identical to value used as data ID keys for
                %   KymoObjFilepathsDataPool (i.e. kymo object filepath)
                %  This allows for the removal of items from
                %   KymoObjFilepathsDataPool based on importItemContext since
                %   the ui list's display names are different from the unique
                %   filepaths which are used as keys in the app data pool
                import Fancy.AppMgr.AppDataPoolMgr;
                import Microscopy.UI.KymoImportScreen;
                AppDataPoolMgr.update_data_items(KymoImportScreen.KymoObjFilepathsDataPoolID, newItemFilepaths, newImportItemContexts);
                kis.sync_ui_list_data();
                if kis.Verbose
                    fprintf('The following paths were added to the list:\n');
                    tableAdded = table(newItemFilepaths(:), 'VariableNames', {'Filepaths'});
                    disp(tableAdded);
                end
            end
            if kis.Verbose && any(dupeItemsMask)
                dupeFilepaths = additionalKymoFilepaths(dupeItemsMask);
                fprintf('The following paths were not added to the list since they were already present:\n');
                tableSkipped = table(dupeFilepaths(:), 'VariableNames', {'Filepaths'});
                disp(tableSkipped);
            end
        end
        
        function [] = sync_ui_list_data(kis)
            kflm = kis.KymoFilepathListManager;
            
            import Microscopy.UI.KymoImportScreen;
            import Fancy.AppMgr.AppDataPoolMgr;
            [importItemContexts, kymoFilepaths] = AppDataPoolMgr.get_data_items(KymoImportScreen.KymoObjFilepathsDataPoolID);
            
            import Fancy.AppMgr.ImportItemContext;
            import Fancy.Utils.FancyStrUtils.make_unique_filepath_display_names;
            kymoFileDisplayNames = make_unique_filepath_display_names(kymoFilepaths);
            
            kflm.set_list_items(kymoFileDisplayNames, importItemContexts); 
        end
        
        function [] = remove_kymo_filepaths(kis, indicesForRemoval)
            kflm = kis.MovieFilepathListManager;
            itemsForRemoval = kflm.get_display_value_pair_list(indicesForRemoval);
            filepathsForRemoval = cellfun(...
                @(importItemContext) ...
                    importItemContext.ImportSrcPath, ...
                itemsForRemoval(:, 2), ...
                'UniformOutput', false);
            
            import Microscopy.UI.KymoImportScreen;
            import Fancy.AppMgr.AppDataPoolMgr;
            dataItemIDsToRemove = filepathsForRemoval;
            [~, ~] = AppDataPoolMgr.remove_data_items(KymoImportScreen.KymoObjFilepathsDataPoolID, dataItemIDsToRemove);
            
            kis.sync_ui_list_data();
            
            % % Todo: consider unloading movies not in the list
            % %  if the user confirms that it is ok and the movie
            % %  isn't otherwise referred to by other data/code
            % unloadKymosMask = false(size(filepathsForRemoval));
            % filepathsForKymosToUnload = filepathsForRemoval(unloadKymosMask);
            % KymoImportScreen.unload_kymo_objects(filepathsForKymosToUnload);
        end
    end
    
    methods (Static)
        function [] = unload_kymo_objects(filepathsForKymosToUnload)
            import Microscopy.UI.KymoImportScreen;
            import Fancy.AppMgr.AppDataPoolMgr;
            kymoDataItemIDsToRemove = filepathsForKymosToUnload;
            [~, ~] = AppDataPoolMgr.remove_data_items(KymoImportScreen.LoadedKymosDataPoolID, kymoDataItemIDsToRemove);
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
    
    methods (Static, Access = private)
        
        function [btnAddItems] = make_add_kymo_filepaths_button_template(kis)
            import Fancy.UI.FancyList.FancyListMgrBtn;

            function add_items_from_prompt(kis)
                import OptMap.DataImport.try_prompt_kymo_mat_filepaths;
                [aborted, additionalKymoFilepaths] = try_prompt_kymo_mat_filepaths();
                if aborted
                    return;
                end

                kis.add_kymo_filepaths(additionalKymoFilepaths);
            end
            buttonText = 'Add kymo filepath(s)';
            callback = @(~, ~, flm) add_items_from_prompt(kis);
            btnAddItems = FancyListMgrBtn(buttonText, callback);
        end
        
        function [btnRemoveItems] = make_remove_kymo_filepaths_button_template(kis)
            import Fancy.UI.FancyList.FancyListMgrBtn;
            function [] = try_remove_selected_items(kis)
                kflm = kis.KymoFilepathListManager;
                indicesForRemoval = kflm.get_selected_indices();

                itemsForRemoval = kflm.get_display_value_pair_list(indicesForRemoval);

                verifyBeforeRemoval = kis.VerifyBeforeRemovals;
                if verifyBeforeRemoval
                    continueRemoval = kis.verify_removal(itemsForRemoval);

                    if not(continueRemoval)
                        return;
                    end
                end
                kis.remove_kymo_filepaths(indicesForRemoval);
            end
            btnRemoveItems = FancyListMgrBtn('Remove kymo filepath(s)', @(~, ~, flm) try_remove_selected_items(kis));
        end
        
        function [btnAddMovieKymos] = make_add_movie_kymos_button_template(kis)
            import Fancy.UI.FancyList.FancyListMgrBtn;
            function [] = try_add_movie_kymos(kis)
                kymoFilepaths
                
                kis.add_kymo_filepaths(kymoFilepaths);
            end
            btnAddMovieKymos = FancyListMgrBtn('Add movie kymo(s)', @(~, ~, flm) try_add_movie_kymos(kis));
        end
        
        function [btnLoadKymos] = make_load_kymo_button_template(kis)
            import Fancy.UI.FancyList.FancyListMgrBtn;
            function [] = try_load_selected_kymos(kis)
                kflm = kis.KymoFilepathListManager;
                indicesForLoading = kflm.get_selected_indices();
                
                kis.load_kymo_objects(indicesForLoading);
            end
            btnLoadKymos = FancyListMgrBtn('Load selected kymo(s)', @(~, ~, flm) try_load_selected_kymos(kis));
        end
        
        function [hKymoImportPanel, hKymoImportTab] = make_import_panel_in_new_tab(ts, tabTitle, deleteFcn)
            
            hKymoImportTab = ts.create_tab(tabTitle, deleteFcn);
            hKymoImportPanel = uipanel(...
                'Parent', hKymoImportTab, ...
                'Position', [0, 0, 1, 1]);
        end
    end
end