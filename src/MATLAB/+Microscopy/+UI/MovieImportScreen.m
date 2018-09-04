classdef MovieImportScreen < handle
    % MOVIEIMPORTSCREEN 
    
    properties (Constant)
        Version = [0, 0, 1];
        MovieFilepathsDataPoolID = 'MovieFilepaths';
        LoadedMoviesDataPoolID = 'LoadedMovies';
    end
    properties (Access = private)
        TabbedScreen
        ImportTabHandle
        ImportPanelHandle
        
        VerifyBeforeRemovals = true;
        Verbose = false;
    end
    properties (SetAccess = private)
        MovieFilepathListManager
    end
    
    
    methods
        function [mis] = MovieImportScreen(ts)
            if nargin < 1
                figTitle = 'Movies';
                import Fancy.UI.FancyTabs.TabbedScreen;
                ts = TabbedScreen.make_tabbed_screen_in_new_fig(figTitle);
            end
            
            import Microscopy.UI.MovieImportScreen;
            MovieImportScreen.create_data_pools();
            
            import Microscopy.UI.MovieImportScreen;
            tabTitle = 'Movie Filepaths';
            deleteFcn = @(varargin) mis.delete();
            [hMovieImportPanel, hMovieImportTab] = MovieImportScreen.make_import_panel_in_new_tab(ts, tabTitle, deleteFcn);
            mis.TabbedScreen = ts;
            mis.ImportTabHandle = hMovieImportTab;
            mis.ImportPanelHandle = hMovieImportPanel;

            import Fancy.UI.FancyList.FancyListMgr;
            mflm = FancyListMgr();
            mis.MovieFilepathListManager = mflm;
            mflm.set_ui_parent(mis.ImportPanelHandle);
            mflm.make_ui_items_listbox();
            
            mis.sync_ui_list_data();
            
            import Fancy.UI.FancyList.FancyListMgr;
            import Fancy.UI.FancyList.FancyListMgrBtnSet;
            
            flmbs1 = FancyListMgrBtnSet();
            flmbs1.NUM_BUTTON_COLS = 2;
            flmbs1.add_button(FancyListMgr.make_select_all_button_template());
            flmbs1.add_button(FancyListMgr.make_deselect_all_button_template());
            flmbs1.add_button(MovieImportScreen.make_add_movie_filepaths_button_template(mis));
            flmbs1.add_button(MovieImportScreen.make_remove_movie_filepaths_button_template(mis));
            
            flmbs2 = FancyListMgrBtnSet();
            flmbs2.NUM_BUTTON_COLS = 1;
            flmbs2.add_button(MovieImportScreen.make_load_movie_button_template(mis));
            
            mflm.add_button_sets(flmbs1, flmbs2);
        end
        
        function delete(mis) % Clean up data super explicitly to reduce any memory leak risk
            if isvalid(mis.MovieFilepathListManager)
                delete(mis.MovieFilepathListManager);
            end
        end
        
        function [] = load_movie_objects(mis, indicesForLoading)
            mflm = mis.MovieFilepathListManager;
            importItemContexts = mflm.get_display_value_pair_list(indicesForLoading);
            
            import Microscopy.GrayscaleMovieFactory;
            movieFactory = GrayscaleMovieFactory.get_instance();
            
            import Microscopy.Import.import_grayscale_tiff_video;
            numFiles = size(importItemContexts, 1);
            for filepathIdx = 1:numFiles
                displayName = importItemContexts{filepathIdx, 1};
                fprintf('::> Loading movie for %s...\n', displayName);
                importItemContext = importItemContexts{filepathIdx, 2};

                [failMsg, gsMovObj] = movieFactory.load_grayscale_movie_from_tiff(importItemContext.ImportSrcPath);
                if any(failMsg)
                    fprintf(' Movie load failure: %s\n', failMsg);
                    fprintf('<:: Failed loading movie for %s\n', displayName);
                else
                    
                    %TODO: consider prompting to prevent
                    %  loading data that is already available
                    %  (since files/code may have changed we shouldn't
                    %   avoid reloading data automatically)
                    import Fancy.AppMgr.AppDataPoolMgr;
                    import Microscopy.UI.MovieImportScreen;
                    loadedMovieDataItemID = importItemContext.ImportSrcPath;
                    AppDataPoolMgr.update_data_item(MovieImportScreen.LoadedMoviesDataPoolID, loadedMovieDataItemID, gsMovObj);

                    fprintf('<:: Loaded movie for %s\n', displayName);
                end
            end
            fprintf(': Completed load attempts for all %d selected movies\n', numFiles);
        end
        
        function [hasFilepaths] = has_movie_filepaths(mis, movieFilepathQueries)
            [~, movieFilepaths] = mis.get_movie_filepaths();
            n = length(movieFilepathQueries);
            hasFilepaths = false(n, 1);
            [~, idxQueries, ~] = intersect(movieFilepathQueries, movieFilepaths);
            hasFilepaths(idxQueries) = true;
        end
        
        function [movieFilepathDisplayNames, movieFilepaths] = get_movie_filepaths(mis)
            listItems = mis.MovieFilepathListManager.get_all_list_items();
            movieFilepathDisplayNames = listItems(:, 1);
            movieImportItemContexts = listItems(:, 2);
            movieFilepaths = cellfun(...
                @(iic) iic.ImportSrcPath ,...
                movieImportItemContexts, ...
                'UniformOutput', false);
        end
        
        function [] = add_movie_filepath(mis, additionalMovieFilepath)
            mis.add_movie_filepaths({additionalMovieFilepath});
        end
        
        function [] = add_movie_filepaths(mis, additionalMovieFilepaths)
            additionalMovieFilepaths = additionalMovieFilepaths(:);
            dupeItemsMask = mis.has_movie_filepaths(additionalMovieFilepaths);
            newItemsMask = not(dupeItemsMask);
            
            import Fancy.AppMgr.ImportItemContext;
            if any(newItemsMask)
                itemSelectionTime = clock();
                newItemFilepaths = additionalMovieFilepaths(newItemsMask);
                newImportItemContexts = cellfun(...
                    @(newItemFilepath) ...
                        ImportItemContext(newItemFilepath, itemSelectionTime), ...
                        newItemFilepaths, ...
                        'UniformOutput', false);
                % Note: ImportSrcPath property of importItemContexts
                %   should be identical to value used as data ID keys for
                %   MovieFilepathsDataPool (i.e. movie filepath)
                %  This allows for the removal of items from
                %   MovieFilepathsDataPool based on importItemContext since
                %   the ui list's display names are different from the unique
                %   filepaths which are used as keys in the app data pool
                import Fancy.AppMgr.AppDataPoolMgr;
                import Microscopy.UI.MovieImportScreen;
                AppDataPoolMgr.update_data_items(MovieImportScreen.MovieFilepathsDataPoolID, newItemFilepaths, newImportItemContexts);
                mis.sync_ui_list_data();
                if mis.Verbose
                    fprintf('The following paths were added to the list:\n');
                    tableAdded = table(newItemFilepaths(:), 'VariableNames', {'Filepaths'});
                    disp(tableAdded);
                end
            end
            if mis.Verbose && any(dupeItemsMask)
                dupeFilepaths = additionalMovieFilepaths(dupeItemsMask);
                fprintf('The following paths were not added to the list since they were already present:\n');
                tableSkipped = table(dupeFilepaths(:), 'VariableNames', {'Filepaths'});
                disp(tableSkipped);
            end
        end
        
        function [] = sync_ui_list_data(mis)
            mflm = mis.MovieFilepathListManager;
            
            import Microscopy.UI.MovieImportScreen;
            import Fancy.AppMgr.AppDataPoolMgr;
            [importItemContexts, movieFilepaths] = AppDataPoolMgr.get_data_items(MovieImportScreen.MovieFilepathsDataPoolID);
            
            import Fancy.AppMgr.ImportItemContext;
            import Fancy.Utils.FancyStrUtils.make_unique_filepath_display_names;
            movieFileDisplayNames = make_unique_filepath_display_names(movieFilepaths);
            
            mflm.set_list_items(movieFileDisplayNames, importItemContexts); 
        end
        
        function [] = remove_movie_filepaths(mis, indicesForRemoval)
            mflm = mis.MovieFilepathListManager;
            itemsForRemoval = mflm.get_display_value_pair_list(indicesForRemoval);
            filepathsForRemoval = cellfun(...
                @(importItemContext) ...
                    importItemContext.ImportSrcPath, ...
                itemsForRemoval(:, 2), ...
                'UniformOutput', false);
            
            import Microscopy.UI.MovieImportScreen;
            import Fancy.AppMgr.AppDataPoolMgr;
            dataItemIDsToRemove = filepathsForRemoval;
            [~, ~] = AppDataPoolMgr.remove_data_items(MovieImportScreen.MovieFilepathsDataPoolID, dataItemIDsToRemove);
            
            mis.sync_ui_list_data();
            
            % % Todo: consider unloading movies not in the list
            % %  if the user confirms that it is ok and the movie
            % %  isn't otherwise referred to by other data/code
            % unloadMoviesMask = false(size(filepathsForRemoval));
            % filepathsForMoviesToUnload = filepathsForRemoval(unloadMoviesMask);
            % MovieImportScreen.unload_movie_objects(filepathsForMoviesToUnload);
        end
    end
    
    methods (Static)
        function [] = create_data_pools()
            import Microscopy.UI.MovieImportScreen;
            import Fancy.AppMgr.AppDataPoolMgr;
            if not(AppDataPoolMgr.has_data_pool(MovieImportScreen.LoadedMoviesDataPoolID))
                AppDataPoolMgr.create_new_data_pool(MovieImportScreen.LoadedMoviesDataPoolID);
            end
            if not(AppDataPoolMgr.has_data_pool(MovieImportScreen.MovieFilepathsDataPoolID))
                AppDataPoolMgr.create_new_data_pool(MovieImportScreen.MovieFilepathsDataPoolID);
            end
        end
        function [] = unload_movie_objects(filepathsForMoviesToUnload)
            import Microscopy.UI.MovieImportScreen;
            import Fancy.AppMgr.AppDataPoolMgr;
            movieDataItemIDsToRemove = filepathsForMoviesToUnload;
            [~, ~] = AppDataPoolMgr.remove_data_items(MovieImportScreen.LoadedMoviesDataPoolID, movieDataItemIDsToRemove);
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
        function [btnAddItems] = make_add_movie_filepaths_button_template(mis)
            import Fancy.UI.FancyList.FancyListMgrBtn;

            function add_items_from_prompt(mis)
                import OptMap.DataImport.try_prompt_movie_filepaths;
                [aborted, additionalMovieFilepaths] = try_prompt_movie_filepaths();
                if aborted
                    return;
                end

                mis.add_movie_filepaths(additionalMovieFilepaths);
            end
            buttonText = 'Add movie filepath(s)';
            callback = @(~, ~, flm) add_items_from_prompt(mis);
            btnAddItems = FancyListMgrBtn(buttonText, callback);
        end
        
        function [btnRemoveItems] = make_remove_movie_filepaths_button_template(mis)
            import Fancy.UI.FancyList.FancyListMgrBtn;
            function [] = try_remove_selected_items(mis)
                mflm = mis.MovieFilepathListManager;
                indicesForRemoval = mflm.get_selected_indices();

                itemsForRemoval = mflm.get_display_value_pair_list(indicesForRemoval);

                verifyBeforeRemoval = mis.VerifyBeforeRemovals;
                if verifyBeforeRemoval
                    continueRemoval = mis.verify_removal(itemsForRemoval);

                    if not(continueRemoval)
                        return;
                    end
                end
                mis.remove_movie_filepaths(indicesForRemoval);
            end
            btnRemoveItems = FancyListMgrBtn('Remove movie filepath(s)', @(~, ~, flm) try_remove_selected_items(mis));
        end
        
        function [btnLoadMovies] = make_load_movie_button_template(mis)
            import Fancy.UI.FancyList.FancyListMgrBtn;
            function [] = try_load_selected_movies(mis)
                mflm = mis.MovieFilepathListManager;
                indicesForLoading = mflm.get_selected_indices();
                
                mis.load_movie_objects(indicesForLoading);
            end
            btnLoadMovies = FancyListMgrBtn('Load selected movie(s)', @(~, ~, flm) try_load_selected_movies(mis));
        end
        
        function [hMovieImportPanel, hMovieImportTab] = make_import_panel_in_new_tab(ts, tabTitle, deleteFcn)
            
            hMovieImportTab = ts.create_tab(tabTitle, deleteFcn);
            hMovieImportPanel = uipanel(...
                'Parent', hMovieImportTab, ...
                'Position', [0, 0, 1, 1]);
        end
    end
end 