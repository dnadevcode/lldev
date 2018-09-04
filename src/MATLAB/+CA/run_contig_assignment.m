function [] = run_contig_assignment(tsCA)

    % Assignment Problem

    fprintf('Running Assignment CAT...\n');

    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appRsrcMgr.add_all_packages();

    %---User input---


    import CA.Import.prompt_ref_barcode_consensus;
    [refBarcode] = prompt_ref_barcode_consensus();
    if isempty(refBarcode)
        fprintf('No reference consensus was provided\n');
        return;
    end
    % Rescale reference curve
    refBarcode = zscore(refBarcode);


    import NtSeq.Import.UI.try_prompt_nt_seq_filepaths;
    [~, contigFilepaths] = try_prompt_nt_seq_filepaths('Select contig fasta files', true, false);
    if isempty(contigFilepaths)
        fprintf('No contigs were selected\n');
        return;
    end


    % Temporary flipped fore image generation
    refBarcode = fliplr(refBarcode);

    %---Get settings for contig assembly---
    % Set input (isDefault) to false to generate a dialog window to manually
    % input settings


    defaultBarcodeGenSettings = get_default_barcode_gen_settings();
    barcodeGenSettings = defaultBarcodeGenSettings;


    % Calculates constants derived from input parameters
    refBarcodeLen_pixels = length(refBarcode);
    numPlacementOptions = refBarcodeLen_pixels;
    import CA.Import.get_contig_assembly_settings_struct;
    [settingsStructCA] = get_contig_assembly_settings_struct();
    if settingsStructCA.flipAllowed
       numPlacementOptions = 2 * numPlacementOptions;
    end
    if not(settingsStructCA.forcePlace)
        numPlacementOptions = numPlacementOptions + 1;
    end

    settingsStructCA.removePvalue = min(0.5, settingsStructCA.pThreshold - 0.01);
    settingsStructCA.clusterThreshold = (2 * log(settingsStructCA.removePvalue))^2;




    % Add the data into objects
    import NtSeq.Import.import_fasta_nt_seqs;
    [contigNtSeqs, contigFastaHeaders] = import_fasta_nt_seqs(contigFilepaths);
    import CA.ContigItem;
    contigItems = cellfun(@ContigItem, contigFastaHeaders, contigNtSeqs);


    % fprintf('There are %d contigs before thresholds\n', length(contigs))

    % Specific function for Linus contigs since they are namned in a certain
    % way. Could be useful for other contigs aswell, but beware that it also
    % may not.
    if (settingsStructCA.shouldFormatNamesTF)
        for contigNum = 1:length(contigItems)
            contigItem = contigItems(contigNum);
            contigItemName = contigItem.name;
            k = strfind(contigItemName, 'contig');

            if isempty(k)
                disp('Could not format contig name, because the keyword "contig" was not found')
                continue;
            end
            contigItemName = contigItemName(k:end);
            contigItem.name = contigItemName;
        end
    end



    for contigNum = 1:length(contigItems)
        % Create the contig barcodes
        contigItems(contigNum).generate_barcode(barcodeGenSettings, settingsStructCA.minValidShortestSeq);
    end


    notRemoved = ~[contigItems.isRemoved];
    keptContigIdxs = allInd(notRemoved);
    fprintf('There are %d contigs left after length threshold.\n', sum(notRemoved))

    import CA.Core.global_rescale;
    [globalMean, globalStd] = global_rescale({contigItems(notRemoved).barcode});
    for contigNum = keptContigIdxs
        contigItems(contigNum).rescale(globalMean, globalStd);
    end

    %---ZM ---
    % ZM preparations

    import CBT.UI.prompt_pregen_zero_model;
    [aborted, meanZeroModelFftFreqMags, zeroModelKbpsPerPixel] = prompt_pregen_zero_model();
    if aborted
        disp('No valid zero-model was provided');
        return;
    end

    % Determine EVD parameters

    % Generate the random barcodes:
    numRandBarcodes = settingsStructCA.numRandBarcodes;
    refLen_pixels = length(refBarcode);
    barcodeKbpsPerPixel = 1 / meanKbpExt_pixel;
    import CBT.RandBarcodeGen.PhaseRandomization.gen_rand_bp_ext_adjusted_zero_model_barcodes;
    randomBarcodes = gen_rand_bp_ext_adjusted_zero_model_barcodes(numRandBarcodes, refLen_pixels, meanZeroModelFftFreqMags, zeroModelKbpsPerPixel, barcodeKbpsPerPixel);

    import CBT.ExpComparison.Core.fit_gumbel_with_zero_model;
    for keptContigIdx = keptContigIdxs
        barcode = contigItems(keptContigIdx).barcode;
        [gumbelCurveMu, gumbelCurveBeta] = fit_gumbel_with_zero_model(...
            barcode, ....
            randomBarcodes, ...
            [], ...
            false, ...
            true, ...
            true);
        contigItems(keptContigIdx).gumbelCurveMu = gumbelCurveMu;
        contigItems(keptContigIdx).gumbelCurveBeta = gumbelCurveBeta;
    end

    %---Main Program---
    % Generate cost matrix
    for keptContigIdx = keptContigIdxs
        contigItems(keptContigIdx).cost_lists_generation(...
            refBarcode, ...
            numPlacementOptions, ...
            settingsStructCA.forcePlace, ...
            settingsStructCA.removePvalue, ...
            settingsStructCA.pThreshold ...
        );
    end
    notRemoved = not([contigItems.isRemoved]);
%             keptInd = allInd(notRemoved);
    fprintf('Cost lists calculated\n')

    % Check if there are one-contig states that could be merged into more-contig states
    import CA.Core.cluster_contigs;
    [clustersContigIdxs, contigClusterAssignments] = cluster_contigs({contigItems(notRemoved).costList}, settingsStructCA.forcePlace, settingsStructCA.clusterThreshold);
    numClusters = length(clustersContigIdxs);
    clusterContigStateCounts = cellfun(@length, clustersContigIdxs);
    for contigNum = 1:length(contigItems)
        contigItems(contigNum).cluster = contigClusterAssignments(contigNum);
        contigItems(contigNum).remove_bad_sites(); % Reduce the cost lists so only relevant costs are saved
    end

    % Merge contig states
    currNonemptyClusterIdx = 1;
    import CA.Core.find_contig_placements_with_brute_force;
    for clusterNum = 1:numClusters
        contigIdxsForCluster = clustersContigIdxs{clusterNum};
        numContigsInCluster = length(contigIdxsForCluster);
        if (numContigsInCluster == 0)
            continue;
        end

        contigItemsInCluster = contigItems(contigIdxsForCluster);


        [potentialContigPlacementsList, costListForContigsInCluster] = find_contig_placements_with_brute_force(...
            contigItemsInCluster, ...
            numPlacementOptions, ...
            settingsStructCA.forcePlace, ...
            settingsStructCA.allowOverlap, ...
            settingsStructCA.overlapLim ...
        );
        fprintf('Length after merge:\n%d\n', length(costListForContigsInCluster));

        for contigIdxInCluster = 1:numContigsInCluster
            currContigItem = contigItemsInCluster(contigIdxInCluster);
            currContigItem.possibleSites = potentialContigPlacementsList;
            currContigItem.costList = costListForContigsInCluster;
            currContigItem.indexInCluster = contigIdxInCluster;
        end

        fprintf('Cluster %d completed\n', currNonemptyClusterIdx);
        currNonemptyClusterIdx = currNonemptyClusterIdx + 1;
    end

    % % %%%% TEST   %%%%%
    % %
    % % pAUsed = find_q_smallest_cost_sums_new_stru(contigs(notRemoved),settings);
    % %
    % % %%%%%%%%%%%%%


    %%%%% REALLY NOT A NICE SOLUTION, ONLY QUICK FIX; MAKE STUFF AFTER THIS NICER%%%%
    costTemp = cell(1, numClusters);
    possibleSitesTemp = costTemp;
    numPosTemp = zeros(1, numClusters);
    for clusterNum = 1:numClusters
        contigItem = contigItems(clustersContigIdxs{clusterNum}(1));
        costTemp{clusterNum} = contigItem.costList;
        possibleSitesTemp{clusterNum} = contigItem.possibleSites;
        numPosTemp(clusterNum) = length(contigItem.possibleSites);
    end
    nonremovedContigBarcodeLens = [contigItems(notRemoved).barcodeLen]';
    import CA.Core.find_q_smallest_columnwise_sums_new_tree;

    contigOrder = [clustersContigIdxs{:}];

    contigsProvided = sum(clusterContigStateCounts);
    if (contigsProvided == 0)
        fprintf('No contigs provided for contig assembly\n');
    end
    [contigPlacementOptionIdxs, ~, actualBestPathNum] = find_q_smallest_columnwise_sums_new_tree(...
        contigOrder, ...
        clusterContigStateCounts, ...
        nonremovedContigBarcodeLens, ...
        ...
        costTemp, ...
        possibleSitesTemp, ...
        numPosTemp, ...
        ...
        settingsStructCA.qMax, ...
        numPlacementOptions, ...
        settingsStructCA.overlapLim, ...
        settingsStructCA.allowOverlap, ...
        settingsStructCA.forcePlace);
    fprintf('Actual q: %d\n', actualBestPathNum);

    refBarcodeLen_pixels = length(refBarcode);

    placementAttemptedContigNum = 0;
    numContigs = length(contigItems);
    for contigNum = 1:numContigs
        contigItem = contigItems(contigNum);
        if contigItem.isRemoved
            continue;
        end
        placementAttemptedContigNum = placementAttemptedContigNum + 1;
        if not(settingsStructCA.forcePlace) && (contigPlacementOptionIdxs(placementAttemptedContigNum) == numPlacementOptions)
            contigItem.isRemoved = true;
            continue;
        end
        if contigPlacementOptionIdxs(placementAttemptedContigNum) > refBarcodeLen_pixels
            contigItem.start = contigPlacementOptionIdxs(placementAttemptedContigNum) - refBarcodeLen_pixels;
            contigItem.barcode = fliplr(contigItems(contigNum).barcode);
            contigItem.flip = true;
        else
            contigItem.start = contigPlacementOptionIdxs(placementAttemptedContigNum);
        end
        contigItem.stop = contigItem.start + contigItem.barcodeLen - 1;
        if contigItem.stop > refBarcodeLen_pixels
            contigItem.stop = contigItem.stop - refBarcodeLen_pixels;
            contigItem.around = true;
        end
    end


    %Plot result
    notRemoved = not([contigItems.isRemoved]);
    placedContigItems = contigItems(notRemoved);

    tabTitle = 'Contig Assembly';
    hTabCA = tsCA.create_tab(tabTitle);
    tsCA.select_tab(hTabCA);
    hPanelCA = uipanel('Parent', hTabCA);
    hAxis = axes('Parent', hPanelCA);
    plotTitleStr = 'Contig Assembly';
    refBarcodeLabel = 'Consensus';
    placedContigLabels = {placedContigItems.name};
    placedContigLabels = placedContigLabels(:);

    numPlacedContigs = length(placedContigItems);
    refContigPlacementValsMat = NaN(refBarcodeLen_pixels, numPlacedContigs);
    for placedContigNum = 1:numPlacedContigs
        placedContigItem = placedContigItems(placedContigNum);
        if placedContigItem.around
            refContigPlacementValsMat(placedContigItem.start:refBarcodeLen_pixels, placedContigNum) = placedContigItem.barcode(1:end-placedContigItem.stop);
            refContigPlacementValsMat(1:placedContigItem.stop, placedContigNum) = placedContigItem.barcode(end-placedContigItem.stop+1:end);
        else
            refContigPlacementValsMat(placedContigItem.start:placedContigItem.stop, placedContigNum) = placedContigItem.barcode;
        end
    end

    import CA.UI.plot_contig_placements;
    meanBpExt_nm = barcodeGenSettings.meanBpExt_nm;
    pixelWidth_nm = barcodeGenSettings.pixelWidth_nm;
    meanKbpExt_pixels = (1000 * meanBpExt_nm) / pixelWidth_nm;
    plot_contig_placements(...
        hAxis, ...
        plotTitleStr, ...
        refBarcode, ...
        refContigPlacementValsMat, ...
        1 / meanKbpExt_pixels, ...
        refBarcodeLabel, ...
        placedContigLabels)
end