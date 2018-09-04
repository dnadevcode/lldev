function run_movie_to_kymos(tsAB, settings)

    
    make_movie_selection_screen(tsAB, settings);
    function make_movie_selection_screen(tsAB, settings)
        import Microscopy.UI.MovieImportScreen;
        mis = MovieImportScreen(tsAB);
        mflm = mis.MovieFilepathListManager;

        import Fancy.UI.FancyList.FancyListMgrBtnSet;

        flmbs = FancyListMgrBtnSet();
        flmbs.NUM_BUTTON_COLS = 1;
        flmbs.add_button(make_extract_kymos_button_template(mis, @on_movie_selection, @on_movie_selections_init));
        mflm.add_button_sets(flmbs);

        
            
        bpsPerPxMap = containers.Map();
        cache = containers.Map();

        loadedMask = false(0, 1);
        function [] = on_movie_selection(gsMovObj, movieNum, numMovies, displayNames)
            movieDisplayName = displayNames{movieNum};
            
            if (length(loadedMask) < numMovies)
                numOldMovies = length(loadedMask);
                numNewMovies = numMovies - numOldMovies;
                loadedMask = [loadedMask; false(numNewMovies, 1)];
                assignin('base', 'displayNames', displayNames);
                

                newMovieDisplayNames = displayNames(end + 1 - (1:numNewMovies));
                fprintf('Waiting for response to movie metadata prompt...\n');
                
                hBpsPerPixelTab = tsAB.create_tab('bps/pixel');
                hBpsPerPixelPanel = uipanel(...
                    'Parent', hBpsPerPixelTab, ...
                    'Position', [0, 0, 1, 1]);
                tsAB.select_tab(hBpsPerPixelTab);
                import OldDBM.General.Import.prompt_files_bps_per_pixel;
                [bpsPerPx, ~] = prompt_files_bps_per_pixel(newMovieDisplayNames, hBpsPerPixelPanel);
                delete(hBpsPerPixelTab);
                waitfor(hBpsPerPixelTab);
                for newMovieNum = 1:numNewMovies
                    bpsPerPxMap(newMovieDisplayNames{newMovieNum}) = bpsPerPx(newMovieNum);
                end
            end
            fprintf('Processing movie...\n');
            
            loadedMask(movieNum)= true;
            

            import AB.Core.run_movie_processing;
            [tsCurrMov, barcodes, barcodeDisplayNames, mprs] = run_movie_processing(tsAB, movieDisplayName, gsMovObj, settings);
            

            hTabConsensuses = tsCurrMov.create_tab('Consensuses');
            hPanelConsensuses = uipanel(hTabConsensuses);
            import Fancy.UI.FancyTabs.TabbedScreen;
            tsConsensuses = TabbedScreen(hPanelConsensuses);

            % TODO: Use bps/pixel for movie processing
            bpsPerPx = bpsPerPxMap(movieDisplayName);
            import AB.Core.run_len_clustered_consensusing;
            [mprs.lenClusterNums, mprs.clusterMeanCenters, mprs.consensusInputs, mprs.consensusStructs, cache] = run_len_clustered_consensusing(tsConsensuses, barcodes, bpsPerPx, barcodeDisplayNames, settings.consensus, cache);
            
            
            fprintf('Saving result for ''%s'' in base workspace\n', movieDisplayName);
            tic
            assignin('base', sprintf('movieProcessingResultsStruct_%d',  movieNum), mprs);
            toc
            fprintf('Saved result in base workspace\n');
        end
        
        function [] = on_movie_selections_init()
            if any(~loadedMask)
                error('must wait until old command terminates');
            end
            
            loadedMask = false(0, 1);
        end
    end

    function [btnLoadMovies] = make_extract_kymos_button_template(mis, fn_on_movie_selection, fn_on_movie_selections_init)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        function [] = try_extract_movie_kymos(mis)
            fn_on_movie_selections_init();
            mflm = mis.MovieFilepathListManager;
            indicesForKymoExtraction = mflm.get_selected_indices();
            movieItemsForKymoExtraction = mflm.get_display_value_pair_list(indicesForKymoExtraction);
            displayNames = movieItemsForKymoExtraction(:, 1);
            importItemContexts = movieItemsForKymoExtraction(:, 2);
            movieFilepathsForKymoExtraction = cellfun(...
                @(importItemContext) ...
                    importItemContext.ImportSrcPath, ...
                importItemContexts, ...
                'UniformOutput', false);

            import Microscopy.GrayscaleMovieFactory;
            movieFactory = GrayscaleMovieFactory.get_instance();

            import Fancy.AppMgr.AppDataPoolMgr;
            import Microscopy.UI.MovieImportScreen;
            MovieImportScreen.create_data_pools();
            dataPoolID = MovieImportScreen.LoadedMoviesDataPoolID;
            dataItemIDs = movieFilepathsForKymoExtraction;
            numFiles = size(importItemContexts, 1);
            gsMovObjs = cell(numFiles, 1);
            for filepathIdx = 1:numFiles
                dataItemID = dataItemIDs{filepathIdx};
                displayName = displayNames{filepathIdx};
                fprintf('::> Loading movie for %s...\n', displayName);
                importItemContext = importItemContexts{filepathIdx};
                [gsMovObj, ~, gsMovObjFoundTF] = AppDataPoolMgr.get_data_item(dataPoolID, dataItemID);
                if not(gsMovObjFoundTF)
                    [failMsg, gsMovObj] = movieFactory.load_grayscale_movie_from_tiff(importItemContext.ImportSrcPath);
                    if any(failMsg)
                        fprintf(' Movie load failure: %s\n', failMsg);
                        fprintf('<:: Failed loading movie for %s\n', displayName);
                        gsMovObj = [];
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
                    gsMovObjs{filepathIdx} = gsMovObj;
                end
                if not(isempty(gsMovObj))
                    fn_on_movie_selection(gsMovObj, filepathIdx, numFiles, displayNames);
                end
            end
        end
        btnLoadMovies = FancyListMgrBtn('Extract movie kymo(s)', @(~, ~, flm) try_extract_movie_kymos(mis));
    end
end
