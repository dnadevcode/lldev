function [] = run_elt(tsELT)
    
    import ELT.ParamsELT;
    paramsELT = ParamsELT();
    paramsELT.prompt_settings_verification();


    import NtSeq.Import.UI.try_prompt_nt_seq_filepaths;
    [~, fastaFilepaths] = try_prompt_nt_seq_filepaths('Select fasta files', true, false);

    import NtSeq.Import.import_fasta_nt_seqs;
    [ntSequences, fastaHeaders] = import_fasta_nt_seqs(fastaFilepaths);
    [~, fastaFilenames, ~] = cellfun(@fileparts, fastaFilepaths, 'UniformOutput', false);


    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    defaultOutputDirpath = appDirpath;
    outputDirpath = uigetdir(defaultOutputDirpath, 'Select output file destination');

    import Microscopy.Simulate.Core.apply_point_spread_function;

    import Fancy.UI.FancyTabs.TabbedScreen;
    numSequences = length(ntSequences);
    for sequenceNum = 1:numSequences
        ntSequence = ntSequences{sequenceNum};
        inputFilename = fastaFilenames{sequenceNum};
        [~, inputFilenameSansExt, ~] = fileparts(inputFilename);

        tabTitleCurrSeq = fastaFilenames{sequenceNum};
        hTabCurrSeq = tsELT.create_tab(tabTitleCurrSeq);
        tsELT.select_tab(hTabCurrSeq);

        hPanelCurrSeq = uipanel(...
            'Parent', hTabCurrSeq, ...
            'Units', 'normalized', ...
            'Position', [0 0 1 1] ...
        );
        tsCurrSeq = TabbedScreen(hPanelCurrSeq);

        import ELT.Core.find_sequence_matches;
        [bindingExpectedMask, numberOfBindings] = find_sequence_matches(paramsELT.bindingSequence, ntSequence);
        predictedCurve = double(bindingExpectedMask);
        % point spread function blurring
        psfSigmaWidth_bp = paramsELT.psfSigmaWidth_nm / paramsELT.meanBpExt_nm;

        predictedCurveAfterPsf = apply_point_spread_function(predictedCurve, psfSigmaWidth_bp, true);


        if paramsELT.shouldPlotExpectedBindingLocs
            hTabPrePsfPlot = tsCurrSeq.create_tab('Pre-psf');
            tsCurrSeq.select_tab(hTabPrePsfPlot);
            hAxisPrePsfPlot = axes( ...
                'Parent', hTabPrePsfPlot ....
            );
            import ELT.UI.plot_expected_binding_locations;
            plot_expected_binding_locations(hAxisPrePsfPlot, predictedCurve, inputFilenameSansExt, paramsELT.bindingSequence);
        end

        if paramsELT.shouldPlotExpectedBarcodePlot
            hTabPostPsfPlot = tsCurrSeq.create_tab('Post-psf');
            tsCurrSeq.select_tab(hTabPostPsfPlot);
            hAxisPostPsfPlot = axes( ...
                'Parent', hTabPostPsfPlot ....
            );
            import ELT.UI.plot_intensity;
            plot_intensity(hAxisPostPsfPlot, predictedCurveAfterPsf, inputFilenameSansExt, paramsELT.bindingSequence);
        end

        if paramsELT.shouldDispExpectedBarcode
            hTabGraphBarcode = tsCurrSeq.create_tab('Barcode');
            tsCurrSeq.select_tab(hTabGraphBarcode);
            hAxisGraphBarcode = axes( ...
                'Parent', hTabGraphBarcode ....
            );
            import ELT.UI.display_barcode;
            display_barcode(hAxisGraphBarcode, predictedCurveAfterPsf);
        end

        if paramsELT.shouldSaveTxtResults
            outputFilename = sprintf('output_%s_in_%s.txt', paramsELT.bindingSequence, inputFilenameSansExt);
            outputFilepath = fullfile(outputDirpath, outputFilename);

            import ELT.Export.export_results_txt;
            export_results_txt(predictedCurveAfterPsf, paramsELT.bindingSequence, inputFilename, outputFilepath);
        end
    end
end