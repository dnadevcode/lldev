classdef NtSeqImportScreen < handle
    % NTSEQIMPORTSCREEN 
    
    properties (Constant)
        Version = [0, 0, 1];
        NtSeqFilepathsDataPoolID = 'NtSeqFilepaths';
        LoadedNtSeqsDataPoolID = 'LoadedNtSeqs';
    end
    properties (Access = private)
        TabbedScreen
        ImportTabHandle
        ImportPanelHandle
        
        VerifyBeforeRemovals = true;
        Verbose = false;
    end
    properties (SetAccess = private)
        NtSeqFilepathListManager
    end
    
    
    methods
        function [nsis] = NtSeqImportScreen(ts)
            if nargin < 1
                figTitle = 'Nucleotide Sequences';
                import Fancy.UI.FancyTabs.TabbedScreen;
                ts = TabbedScreen.make_tabbed_screen_in_new_fig(figTitle);
            end
            
            import NtSeq.UI.NtSeqImportScreen;
            import Fancy.AppMgr.AppDataPoolMgr;
            if not(AppDataPoolMgr.has_data_pool(NtSeqImportScreen.LoadedNtSeqsDataPoolID))
                AppDataPoolMgr.create_new_data_pool(NtSeqImportScreen.LoadedNtSeqsDataPoolID);
            end
            if not(AppDataPoolMgr.has_data_pool(NtSeqImportScreen.NtSeqFilepathsDataPoolID))
                AppDataPoolMgr.create_new_data_pool(NtSeqImportScreen.NtSeqFilepathsDataPoolID);
            end
            
            import NtSeq.UI.NtSeqImportScreen;
            tabTitle = 'Nt Seq Filepaths';
            deleteFcn = @(varargin) nsis.delete();
            [hNtSeqImportPanel, hNtSeqImportTab] = NtSeqImportScreen.make_import_panel_in_new_tab(ts, tabTitle, deleteFcn);
            ts.select_tab(hNtSeqImportTab);
            nsis.TabbedScreen = ts;
            nsis.ImportTabHandle = hNtSeqImportTab;
            nsis.ImportPanelHandle = hNtSeqImportPanel;

            import Fancy.UI.FancyList.FancyListMgr;
            nsflm = FancyListMgr();
            nsis.NtSeqFilepathListManager = nsflm;
            nsflm.set_ui_parent(nsis.ImportPanelHandle);
            nsflm.make_ui_items_listbox();
            
            nsis.sync_ui_list_data();
            
            import Fancy.UI.FancyList.FancyListMgr;
            import Fancy.UI.FancyList.FancyListMgrBtnSet;
            
            flmbs1 = FancyListMgrBtnSet();
            flmbs1.NUM_BUTTON_COLS = 2;
            flmbs1.add_button(FancyListMgr.make_select_all_button_template());
            flmbs1.add_button(FancyListMgr.make_deselect_all_button_template());
            flmbs1.add_button(NtSeqImportScreen.make_add_fasta_filepaths_button_template(nsis));
            flmbs1.add_button(NtSeqImportScreen.make_remove_nt_seq_filepaths_button_template(nsis));
            
            flmbs2 = FancyListMgrBtnSet();
            flmbs2.NUM_BUTTON_COLS = 1;
            flmbs2.add_button(NtSeqImportScreen.make_load_nt_seq_button_template(nsis));
            
            nsflm.add_button_sets(flmbs1, flmbs2);
        end
        
        function delete(nsis) % Clean up data super explicitly to reduce any memory leak risk
            if isvalid(nsis.NtSeqFilepathListManager)
                delete(nsis.NtSeqFilepathListManager);
            end
        end
        
        function [] = load_nt_seq_objects(nsis, indicesForLoading)
            nsflm = nsis.NtSeqFilepathListManager;
            importItemContexts = nsflm.get_display_value_pair_list(indicesForLoading);
            
            import NtSeq.NtSeqObj;
            import NtSeq.Import.import_fasta_nt_seqs;
            import Fancy.AppMgr.AppDataPoolMgr;
            import NtSeq.UI.NtSeqImportScreen;
            numFiles = size(importItemContexts, 1);
            for filepathIdx = 1:numFiles
                displayName = importItemContexts{filepathIdx, 1};
                fprintf('::> Loading sequences for %s...\n', displayName);
                importItemContext = importItemContexts{filepathIdx, 2};
                
                fastaFilepath = importItemContext.ImportSrcPath;
                try
                    [seqFastaHeaders, ntSeqs, ~, seqIdxsInFile] = import_fasta_nt_seqs({fastaFilepath});
                    failMsg = [];
                catch
                    failMsg = 'Failure in importing fasta file sequences';
                end
                if any(failMsg)
                    fprintf(' Sequence load failure\n');
                    fprintf('<:: Failed loading sequences for %s\n', displayName);
                else
                    
                    numSeqs = length(ntSeqs);
                    for seqNum = 1:numSeqs
                        ntSeqObj = NtSeqObj(ntSeqs{seqNum}, seqFastaHeaders{seqNum}, importItemContext, seqIdxsInFile(seqNum));
                        %TODO: consider prompting to prevent
                        %  loading data that is already available
                        %  (since files/code may have changed we shouldn't
                        %   avoid reloading data automatically)
                        loadedNtSeqDataItemID = sprintf('[%d] %s', ntSeqObj.ImportSeqIdxInFile, ntSeqObj.ImportItemContext.ImportSrcPath);
                        AppDataPoolMgr.update_data_item(NtSeqImportScreen.LoadedNtSeqsDataPoolID, loadedNtSeqDataItemID, ntSeqObj);
                    end

                    fprintf('<:: Loaded sequences for %s\n', displayName);
                end
            end
            fprintf(': Completed load attempts for all %d selected sequences\n', numFiles);
        end
        
        function [hasFilepaths] = hs_nt_seq_filepaths(nsis, ntSeqFilepathQueries)
            [~, ntSeqFilepaths] = nsis.get_nt_seq_filepaths();
            n = length(ntSeqFilepathQueries);
            hasFilepaths = false(n, 1);
            [~, idxQueries, ~] = intersect(ntSeqFilepathQueries, ntSeqFilepaths);
            hasFilepaths(idxQueries) = true;
        end
        
        function [ntSeqFilepathDisplayNames, ntSeqFilepaths] = get_nt_seq_filepaths(nsis)
            listItems = nsis.NtSeqFilepathListManager.get_all_list_items();
            ntSeqFilepathDisplayNames = listItems(:, 1);
            ntSeqImportItemContexts = listItems(:, 2);
            ntSeqFilepaths = cellfun(...
                @(iic) iic.ImportSrcPath ,...
                ntSeqImportItemContexts, ...
                'UniformOutput', false);
        end
        
        function [] = add_nt_seq_filepath(nsis, additionalSeqFilepath)
            nsis.add_nt_seq_filepaths({additionalSeqFilepath});
        end
        
        function [] = add_nt_seq_filepaths(nsis, additionalSeqFilepaths)
            additionalSeqFilepaths = additionalSeqFilepaths(:);
            dupeItemsMask = nsis.hs_nt_seq_filepaths(additionalSeqFilepaths);
            newItemsMask = not(dupeItemsMask);
            
            import Fancy.AppMgr.ImportItemContext;
            import Fancy.AppMgr.AppDataPoolMgr;
            import NtSeq.UI.NtSeqImportScreen;
            if any(newItemsMask)
                itemSelectionTime = clock();
                newItemFilepaths = additionalSeqFilepaths(newItemsMask);
                newImportItemContexts = cellfun(...
                    @(newItemFilepath) ...
                        ImportItemContext(newItemFilepath, itemSelectionTime), ...
                        newItemFilepaths, ...
                        'UniformOutput', false);
                % Note: ImportSrcPath property of importItemContexts
                %   should be identical to value used as data ID keys for
                %   NtSeqFilepathsDataPool (i.e. nt seq filepath)
                %  This allows for the removal of items from
                %   NtSeqFilepathsDataPool based on importItemContext since
                %   the ui list's display names are different from the unique
                %   filepaths which are used as keys in the app data pool
                AppDataPoolMgr.update_data_items(NtSeqImportScreen.NtSeqFilepathsDataPoolID, newItemFilepaths, newImportItemContexts);
                nsis.sync_ui_list_data();
                if nsis.Verbose
                    fprintf('The following paths were added to the list:\n');
                    tableAdded = table(newItemFilepaths(:), 'VariableNames', {'Filepaths'});
                    disp(tableAdded);
                end
            end
            if nsis.Verbose && any(dupeItemsMask)
                dupeFilepaths = additionalSeqFilepaths(dupeItemsMask);
                fprintf('The following paths were not added to the list since they were already present:\n');
                tableSkipped = table(dupeFilepaths(:), 'VariableNames', {'Filepaths'});
                disp(tableSkipped);
            end
        end
        
        function [] = sync_ui_list_data(nsis)
            nsflm = nsis.NtSeqFilepathListManager;
            
            import NtSeq.UI.NtSeqImportScreen;
            import Fancy.AppMgr.AppDataPoolMgr;
            [importItemContexts, ntSeqFilepaths] = AppDataPoolMgr.get_data_items(NtSeqImportScreen.NtSeqFilepathsDataPoolID);
            
            import Fancy.AppMgr.ImportItemContext;
            import Fancy.Utils.FancyStrUtils.make_unique_filepath_display_names;
            ntSeqDisplayNames = make_unique_filepath_display_names(ntSeqFilepaths);
            
            nsflm.set_list_items(ntSeqDisplayNames, importItemContexts); 
        end
        
        function [] = remove_nt_seq_filepaths(nsis, indicesForRemoval)
            nsflm = nsis.NtSeqFilepathListManager;
            itemsForRemoval = nsflm.get_display_value_pair_list(indicesForRemoval);
            filepathsForRemoval = cellfun(...
                @(importItemContext) ...
                    importItemContext.ImportSrcPath, ...
                itemsForRemoval(:, 2), ...
                'UniformOutput', false);
            
            import NtSeq.UI.NtSeqImportScreen;
            import Fancy.AppMgr.AppDataPoolMgr;
            dataItemIDsToRemove = filepathsForRemoval;
            [~, ~] = AppDataPoolMgr.remove_data_items(NtSeqImportScreen.NtSeqFilepathsDataPoolID, dataItemIDsToRemove);
            
            nsis.sync_ui_list_data();
            
            % % Todo: consider unloading nt seqs not in the list
            % %  if the user confirms that it is ok and the nt seq
            % %  isn't otherwise referred to by other data/code
            % unloadSeqsMask = false(size(filepathsForRemoval));
            % filepathsForSeqsToUnload = filepathsForRemoval(unloadSeqsMask);
            % NtSeqImportScreen.unload_nt_seq_objects(filepathsForSeqsToUnload);
        end
    end
    
    methods (Static)
        function [] = unload_nt_seq_objects(filepathsForNtSeqsToUnload)
            import NtSeq.UI.NtSeqImportScreen;
            import Fancy.AppMgr.AppDataPoolMgr;
            [dataItemIDs] = get_pool_data_item_ids(NtSeqImportScreen.LoadedNtSeqsDataPoolID);
            removalMask = false(size(dataItemIDs));
            for idx = 1:length(dataItemIDs)
                dataItemID = dataItemIDs{idx};
                for idx2 = 1:length(filepathsForNtSeqsToUnload)
                    filepathForNtSeqsToUnload = filepathsForNtSeqsToUnload{idx2};
                    lenTmp = length(filepathForNtSeqsToUnload);
                    if length(dataItemID) < lenTmp
                        continue;
                    end
                    
                    removalMask(idx) = strcmp(dataItemID((1:lenTmp) + (end - lenTmp)), filepathForNtSeqsToUnload);
                end
            end
            ntSeqDataItemIDsToRemove = dataItemIDs(removalMask);
            [~, ~] = AppDataPoolMgr.remove_data_items(NtSeqImportScreen.LoadedNtSeqsDataPoolID, ntSeqDataItemIDsToRemove);
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
        function [btnAddItems] = make_add_fasta_filepaths_button_template(nsis)
            import Fancy.UI.FancyList.FancyListMgrBtn;

            function add_items_from_prompt()
                import NtSeq.Import.UI.try_prompt_nt_seq_filepaths;
                [aborted, ntSeqFilepaths] = try_prompt_nt_seq_filepaths([], true);
                if aborted
                    return;
                end

                nsis.add_nt_seq_filepaths(ntSeqFilepaths)
            end
            buttonText = 'Add fasta filepath(s)';
            callback = @(~, ~, flm) add_items_from_prompt();
            btnAddItems = FancyListMgrBtn(buttonText, callback);
        end
        
        function [btnRemoveItems] = make_remove_nt_seq_filepaths_button_template(nsis)
            import Fancy.UI.FancyList.FancyListMgrBtn;
            function [] = try_remove_selected_items()
                nsflm = nsis.NtSeqFilepathListManager;
                indicesForRemoval = nsflm.get_selected_indices();

                itemsForRemoval = nsflm.get_display_value_pair_list(indicesForRemoval);

                verifyBeforeRemoval = nsis.VerifyBeforeRemovals;
                if verifyBeforeRemoval
                    continueRemoval = nsis.verify_removal(itemsForRemoval);

                    if not(continueRemoval)
                        return;
                    end
                end
                nsis.remove_nt_seq_filepaths(indicesForRemoval);
            end
            btnRemoveItems = FancyListMgrBtn('Remove filepath(s)', @(~, ~, flm) try_remove_selected_items());
        end
        
        function [btnLoadSeqs] = make_load_nt_seq_button_template(nsis)
            import Fancy.UI.FancyList.FancyListMgrBtn;
            function [] = try_load_selected_nt_Seqs()
                nsflm = nsis.NtSeqFilepathListManager;
                indicesForLoading = nsflm.get_selected_indices();
                
                nsis.load_nt_seq_objects(indicesForLoading);
            end
            btnLoadSeqs = FancyListMgrBtn('Load selected file(s)', @(~, ~, flm) try_load_selected_nt_Seqs());
        end
        
        function [hNtSeqImportPanel, hNtSeqImportTab] = make_import_panel_in_new_tab(ts, tabTitle, deleteFcn)
            
            hNtSeqImportTab = ts.create_tab(tabTitle, deleteFcn);
            hNtSeqImportPanel = uipanel(...
                'Parent', hNtSeqImportTab, ...
                'Position', [0, 0, 1, 1]);
        end
    end
end 