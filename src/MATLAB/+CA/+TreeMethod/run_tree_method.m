function [] = run_tree_method(tsCA)

    fprintf('Running contig assembly tree method...\n');

    import CA.Import.prompt_cat_settings;
    settingsStruct = prompt_cat_settings(0.9, false);
    numPixelsTrimmed = settingsStruct.numPixelsTrimmed;
    dataSampleName = settingsStruct.dataSampleName;
    sValueThreshold = settingsStruct.sValueThreshold;
    isPlasmidTF = settingsStruct.isPlasmid;
    contigsShareSameDirTF = settingsStruct.contigsShareSameDir;
    isFullyCoveredTF = settingsStruct.isFullyCovered;

    minimalSeqLen = 6421; % why this value?


    import CA.Import.prompt_ref_barcode_consensus;
    [refBarcode] = prompt_ref_barcode_consensus();
    if isempty(refBarcode)
        fprintf('No reference consensus was provided\n');
        return;
    end
    % Rescale reference curve
    scaledRefBarcode = zscore(refBarcode);

    import CBT.get_default_barcode_gen_settings;
    defaultBarcodeGenSettings = get_default_barcode_gen_settings();
    barcodeGenSettings = defaultBarcodeGenSettings;

    bpsPerPixel = barcodeGenSettings.pixelWidth_nm/barcodeGenSettings.meanBpExt_nm;


    import NtSeq.Import.UI.try_prompt_nt_seq_filepaths;
    [~, contigFilepaths] = try_prompt_nt_seq_filepaths('Select contig fasta files', true, false);

    import NtSeq.Import.import_fasta_nt_seqs;
    [contigNtSeqs, contigFastaHeaders] = import_fasta_nt_seqs(contigFilepaths);

    contigSequenceLens = cellfun(@length, contigNtSeqs);
    contigNtSeqs = contigNtSeqs(contigSequenceLens >= minimalSeqLen);

    import CBT.Core.gen_unscaled_cbt_barcode;
    contigBarcodes = cellfun( ...
        @(contigSequence) ...
            gen_unscaled_cbt_barcode(contigSequence,  barcodeGenSettings), ...
        contigNtSeqs, ...
        'UniformOutput', false);

    croppedContigBarcodes = cellfun(@(contigBarcode) contigBarcode(1+numPixelsTrimmed:end-numPixelsTrimmed), contigBarcodes, 'UniformOutput', false);
    croppedContigBarcodes = croppedContigBarcodes(not(cellfun(@isempty, croppedContigBarcodes)));

    if isempty(croppedContigBarcodes)
        fprintf('No contigs were selected\n');
        return;
    end


   % numPixelsTrimmed Should be no more than 4. % why this value? (meant for wiggle room?)



    % Set the lower limit for contig lengths
    if not(isFullyCoveredTF)
        minimalCroppedContigLen_px = 4;
    else
        lowLimPrompt = { ...
                'Lower limit on contig length (kbp):' ...
            };
        defaultValsLim = { ...
                num2str(12) ...
            };
        dlg_titleLim = 'Lower limit contig';
        answers = inputdlg(lowLimPrompt, dlg_titleLim, num_lines, defaultValsLim);
        minimalCroppedContigLen_kbps = str2double(answers{1});
        minimalCroppedContigLen_bps = 1000*minimalCroppedContigLen_kbps;
        minimalCroppedContigLen_px = round(minimalCroppedContigLen_bps/bpsPerPixel);
    end

    % Removes contigs that are too small to bother with
    passesMinimalLenMask = (cellfun(@length, croppedContigBarcodes) >= minimalCroppedContigLen_px);
    croppedContigBarcodes = croppedContigBarcodes(passesMinimalLenMask);

    lowerBoundRef = 4; % The shortest length



    import CA.Core.find_contig_placements_with_tree_method;
    [contigOrderingsMat, startMat, sValsByBranch, coverageByBranch, flippedMat] = find_contig_placements_with_tree_method(...
        scaledRefBarcode, ...
        croppedContigBarcodes, ...
        bpsPerPixel, ...
        sValueThreshold, ...
        isPlasmidTF, ...
        contigsShareSameDirTF, ...
        isFullyCoveredTF, ...
        lowerBoundRef);



    import CA.Core.calc_tree_method_svals_mat;
    sValsHistMat = calc_tree_method_svals_mat(croppedContigBarcodes, contigOrderingsMat, startMat, sValsByBranch, coverageByBranch);


    %---Create result image---
    fprintf('Finished running the Tree method program\n');
    fprintf('Displaying result window\n')


    tabTitle = 'Contig Assembly (Tree Method - Branch histogram)';
    hTabCATM = tsCA.create_tab(tabTitle);
    tsCA.select_tab(hTabCATM);
    hPanelCATM = uipanel('Parent', hTabCATM);
    
    import Fancy.UI.FancyTabs.TabbedScreen;
    tsCATM = TabbedScreen(hPanelCATM);
    
    import CA.TreeMethod.UI.display_tree_method_results;
    display_tree_method_results(tsCATM, scaledRefBarcode, croppedContigBarcodes, passesMinimalLenMask, bpsPerPixel, dataSampleName, numPixelsTrimmed, contigOrderingsMat, startMat, sValsByBranch, coverageByBranch, flippedMat, sValsHistMat);
end