function [] = run_free_energy_method(tsCA)
    % Assembles contigs with the Free Energy method. The energy part is given
    % by converting s-values into energy using F = -2*ln(s) and the entropy
    % part is given by the number of overlapping contig pixels and adding a
    % given energy cost for that.
    fprintf('Running Free Energy Contig Assembly...\n')
    %---User input---


    %---Load reference barcode---

    import CA.Import.prompt_ref_barcode_consensus;
    [refBarcode] = prompt_ref_barcode_consensus();
    if isempty(refBarcode)
        fprintf('No reference consensus was provided\n');
        return;
    end
    % Rescale reference curve
    refBarcode = zscore(refBarcode);

    % Manual input for main_contig

    import CA.Import.prompt_cat_settings;
    settingsStruct = prompt_cat_settings(0.2, true);
    numPixelsTrimmed = settingsStruct.numPixelsTrimmed;
    isFullyCoveredTF = settingsStruct.isFullyCovered;
    contigsShareSameDirTF = settingsStruct.contigsShareSameDir;
    isPlasmidTF = settingsStruct.isPlasmid;
    sValueThreshold = settingsStruct.sValueThreshold;
    overlapCost = settingsStruct.overlapCost;
    dataSampleName = settingsStruct.dataSampleName;

    % Constants
    import CBT.get_default_barcode_gen_settings;
    defaultBarcodeGenSettings = get_default_barcode_gen_settings();
    barcodeGenSettings = defaultBarcodeGenSettings;

    meanBpExt_pixels = barcodeGenSettings.meanBpExt_nm/barcodeGenSettings.pixelWidth_nm;

    minimalAllowedContigBarcodeLen_pixels = 7; % minimal length of acceptable contig barcodes after being trimmed
    minimalAllowedContigSrcSeqLen_bps = ceil((minimalAllowedContigBarcodeLen_pixels + 2*numPixelsTrimmed)/meanBpExt_pixels);


    % Set the lower limit for contig lengths
    if (isFullyCoveredTF)
        import CA.FreeEnergyMethod.Import.prompt_minimal_contig_len;
        lowLim_pixels = prompt_minimal_contig_len(meanBpExt_pixels);
    else
        lowLim_pixels = 4;
    end

    import NtSeq.Import.UI.try_prompt_nt_seq_filepaths;
    [~, contigSeqFilepaths] = try_prompt_nt_seq_filepaths('Select contig fasta files', true, false);
    if isempty(contigSeqFilepaths)
        fprintf('No contigs were selected\n');
        return;
    end

    import CA.Import.import_nt_seqs_with_minlen;
    ntContigSeqs = import_nt_seqs_with_minlen(minimalAllowedContigSrcSeqLen_bps, contigSeqFilepaths);
    import CBT.Core.gen_unscaled_cbt_barcode;
    croppedContigBarcodes = cellfun(@(ntSeq) gen_unscaled_cbt_barcode(ntSeq, barcodeGenSettings), ntContigSeqs, 'UniformOutput', false);

    import CA.Core.trim_contig_barcodes;
    croppedContigBarcodes = trim_contig_barcodes(croppedContigBarcodes, numPixelsTrimmed);

    % Rescale all the contigs
    croppedContigBarcodes = cellfun(@(contigBarcode) contigBarcode(:)', croppedContigBarcodes, 'UniformOutput', false); % make sure they are all horizontal
    aggregatedPlacedContigVals = horzcat(croppedContigBarcodes{:}); % concatenate them all
    globalRescaleMean = nanmean(aggregatedPlacedContigVals);
    globalRescaleStd = nanstd(aggregatedPlacedContigVals);
    croppedContigBarcodes = cellfun(...
        @(croppedContigBarcode) (croppedContigBarcodes - globalRescaleMean)/globalRescaleStd, ...
        croppedContigBarcodes, ...
        'UniformOutput', false);

    % Determine direction
    if contigsShareSameDirTF
        [~, maxLenIdx] = max(cellfun(@length, croppedContigBarcodes(:)));
        largestContig = croppedContigBarcodes{maxLenIdx};
        import CBT.ExpComparison.Core.GrossCcorr.ccorr_all_based_flipcheck;
        flipContigsTF2 = ccorr_all_based_flipcheck(...
            refBarcode, ...
            largestContig, ...
            isPlasmidTF, ...
            not(isFullyCoveredTF) ...
        );
        if flipContigsTF2
            croppedContigBarcodes = cellfun(@fliplr, croppedContigBarcodes, 'UniformOutput', false);
        end
    end

    % Removes empty contigs
    jRemove = 1;
    removedEarly = zeros(1,length(croppedContigBarcodes));
    for iRemove = fliplr(1:length(croppedContigBarcodes))
        if length(croppedContigBarcodes{iRemove}) < lowLim_pixels
            croppedContigBarcodes(iRemove) = [];
            removedEarly(jRemove) = iRemove;
            jRemove = jRemove + 1;
        end
    end
    removedEarly(removedEarly==0) = [];


    % Removes contigs that are too small to bother with
    contigBarcodeLens_pixels = cellfun(@length, croppedContigBarcodes);
    [maxContigBarcodeLen_px, ~] = max(contigBarcodeLens_pixels);



    barcodeBpsPerPixel = barcodeGenSettings.pixelWidth_nm/barcodeGenSettings.meanBpExt_nm;

    import CA.Core.make_fn_gen_gumbel_params_wrapper;
    [failMsg, fn_gen_gumbel_params_wrapper] = make_fn_gen_gumbel_params_wrapper(...
        length(refBarcode), ...
        maxContigBarcodeLen_px, ...
        barcodeBpsPerPixel, ...
        isPlasmidTF ...
    );
    if any(failMsg)
        disp(failMsg);
        return;
    end

    import CA.FreeEnergyMethod.Core.calc_ccs_mats;
    [ccValsUnflipped, ccValsFlipped] = calc_ccs_mats(refBarcode, croppedContigBarcodes, isPlasmidTF, isFullyCoveredTF);

    import CA.FreeEnergyMethod.Core.calc_svals_mat;
    [sValsMat] = calc_svals_mat(refBarcode, croppedContigBarcodes, ccValsUnflipped, ccValsFlipped, fn_gen_gumbel_params_wrapper);

    % Calculate which positions to consider and related indecies
    threshedSValsMat = sValsMat <= sValueThreshold;
    indVecMax = sum(threshedSValsMat,2)';
    removedContigsMask = (indVecMax == 0);
    longInd = max(indVecMax);

    startMatBig = zeros(size(threshedSValsMat));
    for iStartBig = 1:length(croppedContigBarcodes)
        startMatBig(iStartBig,:) = 1:2*length(refBarcode);
    end
    startMatBig = startMatBig.*threshedSValsMat;
    startMat = zeros(length(croppedContigBarcodes),longInd);
    for iStart = 1:length(croppedContigBarcodes)
        startMat(iStart,1:sum(startMatBig(iStart,:)~=0)) = startMatBig(iStart,(startMatBig(iStart,:)~=0));
    end

    % Remove contigs that have 0 possible sites
    croppedContigBarcodes(removedContigsMask) = [];
    if isempty(croppedContigBarcodes)
        fprintf('No contigs passed the S-value threshold\n');
        fprintf('Program finished\n');
        return;
    end
    startMat(removedContigsMask,:) = [];
    indVecMax(removedContigsMask) = [];
    sValsMat(removedContigsMask,:) = [];

    import CA.FreeEnergyMethod.Core.find_contig_placements_using_free_energy_method;
    [contigPlacementOptionIdxsByBranch, sValsByBranch, numTotalOverlapsByBranch] = find_contig_placements_using_free_energy_method(refBarcode, croppedContigBarcodes, sValsMat, indVecMax, overlapCost, startMat);

    sValsByBranch = sortrows([sValsByBranch (1:size(sValsByBranch,1))']);
    contigPlacementOptionIdxsByBranch = contigPlacementOptionIdxsByBranch(sValsByBranch(:,2),:);

    %Fix removeContig vector
    jF = 1;
    kF = 1;
    removeContigTemp = false(1, length(removedEarly) + length(removedContigsMask));
    for iF = removedEarly
        removeContigTemp(jF:iF) = [removedContigsMask((jF:(iF - 1)) + (kF - jF)), false];
        kF = kF + length(jF:iF-1);
        jF = iF + 1;
    end
    removeContigTemp(jF:end) = removedContigsMask(kF:end);
    removedContigsMask = removeContigTemp;

    placedContigMask = not(removedContigsMask);
    placedContigBarcodes = croppedContigBarcodes;


    fprintf('Finished running the Free Energy program\n');
    fprintf('Displaying result window\n')


    import CA.FreeEnergyMethod.UI.display_free_energy_contig_placement_results;
    display_free_energy_contig_placement_results(...
        tsCA, ...
        refBarcode, ...
        placedContigBarcodes, ...
        placedContigMask, ...
        dataSampleName, ...
        meanKbpExt_pixels, ...
        sValsByBranch, ...
        numTotalOverlapsByBranch, ...
        contigPlacementOptionIdxsByBranch ...
        );
end