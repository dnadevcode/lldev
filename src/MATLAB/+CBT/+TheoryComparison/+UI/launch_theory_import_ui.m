function [] = launch_theory_import_ui(ctrlStruct, ts, already_have_theory_loaded, on_load_completion, on_theory_load_start, on_theory_load_end, on_compare_theories_vs_theories, on_load_experiment_curves)
    

    if not(isfield(ctrlStruct, 'numTheorySequencesLoaded'))
        ctrlStruct.numTheorySequencesLoaded = 0;
    end

    if not(isfield(ctrlStruct, 'numTheorySequencesRemaining'))
        ctrlStruct.numTheorySequencesRemaining = 0;
    end

    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    flmbs = FancyListMgrBtnSet();
    flmbs.NUM_BUTTON_COLS = 1;
    flmbs.add_button(make_gen_theory_curves_button());
    flmbs.add_button(make_compare_selected_theories_vs_all_theories_button(ts, on_compare_theories_vs_theories));
    flmbs.add_button(make_compare_selected_theories_vs_exps_from_consensus_button(ts, on_load_experiment_curves));
    
    import NtSeq.UI.NtSeqImportScreen;
    nsis = NtSeqImportScreen(ts);
    nsflm = nsis.NtSeqFilepathListManager;
    nsflm.add_button_sets(flmbs);
    
    
    function outer_on_load_start(err, theoryStruct)
        theoryFilepath = theoryStruct.sourceFilepath;
        [~, theoryStruct.displayName, ~] = fileparts(theoryFilepath);
        on_theory_load_start(err, theoryStruct);
    end
    function outer_on_load_end(err, theoryStruct)
        import Fancy.Utils.data_hash;
        
        [~, theoryStruct.displayName, ~] = fileparts(theoryStruct.sourceFilepath);
        theoryStruct.dataHash = data_hash(theoryStruct.sequenceData);
        ctrlStruct.numTheorySequencesLoaded = ctrlStruct.numTheorySequencesLoaded + 1;
        ctrlStruct.numTheorySequencesRemaining = ctrlStruct.numTheorySequencesRemaining - 1;
        on_theory_load_end(err, theoryStruct, ctrlStruct.numTheorySequencesLoaded, (ctrlStruct.numTheorySequencesLoaded + ctrlStruct.numTheorySequencesRemaining));
        if (ctrlStruct.numTheorySequencesRemaining == 0)
            on_load_completion(false, ctrlStruct);
        end
    end
    function filepathsToLoad = get_all_unloaded_filepaths(allItemsToLoad)
        displayNames = allItemsToLoad(:, 1);
        importItemContextsToLoad = allItemsToLoad(:, 2);
        filepathsToLoad = cellfun(...
            @(iic) iic.ImportSrcPath, ...
            importItemContextsToLoad, ...
            'UniformOutput', false);
        
        numItems = size(filepathsToLoad, 1);
        alreadedLoadedMask = false(numItems, 1);
        for itemNum = 1:numItems
            displayName = displayNames{itemNum};
            filepath = filepathsToLoad{itemNum};
            [~, keyName, ~] = fileparts(displayName);
            alreadedLoadedMask(itemNum) = already_have_theory_loaded(keyName, filepath);
        end
        filepathsToLoad = filepathsToLoad(not(alreadedLoadedMask));
    end

    function filename = remove_extension(filename)
        [~, filename, ~] = fileparts(filename);
    end
    function filenames = remove_extensions(filenames)
        filenames = cellfun(@remove_extension, filenames, 'UniformOutput', false);
    end

    function [btnGenTheoryCurves] = make_gen_theory_curves_button()
        function generate_theory_curves(lm)
            import CBT.TheoryComparison.Import.async_theory_sequence_imports;

            allItems = lm.get_all_list_items();
            filepathsToLoad = get_all_unloaded_filepaths(allItems);
            if isempty(filepathsToLoad)
                disp('All theory curves have been generated');
                return;
            end

            if not(isfield(ctrlStruct, 'numTheorySequencesRemaining'))
                ctrlStruct.numTheorySequencesRemaining = 0;
            end
            ctrlStruct.numTheorySequencesRemaining = ctrlStruct.numTheorySequencesRemaining + length(filepathsToLoad);
            disp('Starting to load theory sequences');
            async_theory_sequence_imports(filepathsToLoad, @outer_on_load_start, @outer_on_load_end);
        end
        
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnGenTheoryCurves = FancyListMgrBtn('Generate All Theory Curve(s)', @(~, ~, lm) generate_theory_curves(lm));
    end

    function [btnCompareTvT] = make_compare_selected_theories_vs_all_theories_button(ts, on_compare_theories_vs_theories)
        function compare_theories_vs_theories(lm, ts, on_compare_theories_vs_theories)
            allItems = lm.get_all_list_items();
            selectedItems = lm.get_selected_list_items();
            filepathsToLoad = get_all_unloaded_filepaths(allItems);
            if not(isempty(filepathsToLoad))
                questdlg('You must generate the theory curves first!', 'Not Yet!', 'OK', 'OK');
                return;
            end

            theoryDisplayNamesA = remove_extensions(selectedItems(:, 1));
            theoryDisplayNamesB = remove_extensions(allItems(:, 1));
            lenA = length(theoryDisplayNamesA);
            lenB = length(theoryDisplayNamesB);
            if ((lenA < 1) || (lenB < 1))
                questdlg('You must select some theory curves first!', 'Not Yet!', 'OK', 'OK');
                return;
            end
            switch questdlg(['Calculate cross-correlation stats for ', num2str(lenA), ' theories against ', num2str(lenB), ' theories?'], 'Calculation Confirmation', 'Continue', 'Continue')
                case 'Continue'
                    on_compare_theories_vs_theories(ts, theoryDisplayNamesA, theoryDisplayNamesB);
            end

        end
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnCompareTvT = FancyListMgrBtn('Selected Theories vs All Theories', @(~, ~, lm) compare_theories_vs_theories(lm, ts, on_compare_theories_vs_theories));
    end

    function [btnCompareTvE] = make_compare_selected_theories_vs_exps_from_consensus_button(ts, on_load_experiment_curves)
        function load_experiment_curves(lm, ts, on_load_experiment_curves)
            selectedItems = lm.get_selected_list_items();
            filepathsToLoad = get_all_unloaded_filepaths(selectedItems);
            if not(isempty(filepathsToLoad))
                questdlg('You must generate the theory curves first!', 'Not Yet!', 'OK', 'OK');
                return;
            end

            theoryDisplayNames = remove_extensions(selectedItems(:, 1));
            lenTheories = length(theoryDisplayNames);
            if lenTheories < 1
                questdlg('You must select some theory curves first!', 'Not Yet!', 'OK', 'OK');
                return;
            end

            % Handle response
            switch questdlg(['Calculate cross-correlation stats for ', num2str(lenTheories), ' theories against experiments (yet to be loaded)?'], 'Calculation Confirmation', 'Continue', 'Continue')
                case 'Continue'
                    on_load_experiment_curves(ts, theoryDisplayNames);
            end
        end
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnCompareTvE = FancyListMgrBtn('Selected Theories vs Experiment Curves from DBM Sessions', @(~, ~, lm) load_experiment_curves(lm, ts, on_load_experiment_curves));
    end

end