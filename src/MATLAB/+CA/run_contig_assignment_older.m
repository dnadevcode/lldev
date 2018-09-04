function [] = run_contig_assignment_older(tsCA)
    % Contig assembly using the assignment approach

    % 3442 bps/micrometer for PLOS005

    fprintf('Running Assignment Contig Assembly...\n');

    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appRsrcMgr.add_all_packages();

    % Settings
    qMax = round(5*10^5);
    pThreshold = 0.51;
    removePvalue = min(0.5,pThreshold-0.01);
    clusterThreshold = (2*log(removePvalue))^2;
    edgeCut = 0;
    numRandBarcodes = 1000; %number of PR barcodes


    import CA.Import.prompt_ref_barcode_consensus;
    [refBarcode] = prompt_ref_barcode_consensus();
    if isempty(refBarcode)
        fprintf('No reference consensus was provided\n');
        return;
    end
    % Rescale reference curve
    refBarcode = zscore(refBarcode);


    import NtSeq.Import.UI.try_prompt_nt_seq_filepaths;
    [~, contigFastaFilepaths] = try_prompt_nt_seq_filepaths('Select contig fasta files', true, false);
    if isempty(contigFastaFilepaths)
        fprintf('No contigs were selected\n');
        return;
    end

    import NtSeq.Import.import_fasta_nt_seqs;
    [contigNtSeqs, contigFastaHeaders] = import_fasta_nt_seqs(contigFastaFilepaths);


    % Manual input for main_contig
    prompts = { ...
        'Name of sample:', ...
        'Force place contigs:', ...
        'Allowed overlap (px):', ...
    };
    defaultVals = { ...
        'Unknown', ...
        'No', ...
        num2str(2) ...
    };
    dlg_title = 'CA Inputs';
    num_lines = 1;
    answers = inputdlg(prompts,dlg_title,num_lines,defaultVals);

    %---Input parameters dialog 1---
    dataSampleName = answers{1};
    forcePlacementTF = not(strcmpi(answers{2}(1),'N'));
    overlapLim = str2double(answers{3});

    import CBT.UI.prompt_barcode_gen_settings;
    barcodeGenSettings = prompt_barcode_gen_settings();

    pixelWidth_nm = barcodeGenSettings.pixelWidth_nm;
    meanBpExt_nm = barcodeGenSettings.meanBpExt_nm;
    psfSigmaWidth_nm = barcodeGenSettings.psfSigmaWidth_nm;

    minimalSeqLen_bps = 4 * psfSigmaWidth_nm / meanBpExt_nm;

    % shortestSeq = 40000;


    % TODO: remove
    % % Temporary code to flip for image generation (only PLOS005B and pUUH)
    % if strcmp(dataSampleName,'pUUH') || strcmp(dataSampleName,'PLOS005B')
    %     refBarcode = fliplr(refBarcode);
    % end

    %---Make contig barcodes---
    % Load contig sequences



    % Specific function for Linus contigs since they are namned in a certain
    % way. Recommended to remove this for other data.
    % Cuts out the relevant part of the contig names
    numContigs = length(contigFastaHeaders);

    function contigName = clean_contig_display_name(contigNum, oldContigFastaHeaderStr)
        defaultContigName = sprintf('contig %d', contigNum);
        idxStrContig = strfind(oldContigFastaHeaderStr, 'contig');
        contigName = oldContigFastaHeaderStr(idxStrContig:end);
        contigName = strrep(contigName, '_', ' ');
        if isempty(contigName)
            contigName = defaultContigName;
        end
    end
    contigNames = arrayfun(...
        @(contigNum) clean_contig_display_name(contigNum, contigFastaHeaders{contigNum}), ...
        1:numContigs, ...
        'UniformOutput', false);


    % fprintf('There are %d contigs before thresholds\n', length(ntSeqs));
    % Create the contig barcodes


    numBarcodes = length(contigNtSeqs);
    seqLens = cellfun(@length, contigNtSeqs(:));
    removalMask = (seqLens < minimalSeqLen_bps);
    nonremovedBarcodeIdxs = find(not(removalMask));
    barcodes = cell(numBarcodes, 1);
    import CBT.Core.gen_unscaled_cbt_barcode;
    for nonremovedBarcodeNum = nonremovedBarcodeIdxs
        ntSeq = contigNtSeqs{nonremovedBarcodeNum};
        seqLen = length(ntSeq);
        tmpBarcodeGenSettings = barcodeGenSettings;
        if (seqLen <= 2*minimalSeqLen_bps)
            tmpBarcodeGenSettings.widthSigmasFromMean = 2;
        else
            tmpBarcodeGenSettings.widthSigmasFromMean = 4;
        end
        unscaledBarcode_pxRes = gen_unscaled_cbt_barcode(ntSeq, tmpBarcodeGenSettings);
        barcodes{nonremovedBarcodeNum} = unscaledBarcode_pxRes;
    end
    croppedBarcodes = cellfun(@(barcode) barcode(1+edgeCut:end-edgeCut), barcodes);

    croppedBarcodes(removalMask) = [];
    contigNames(removalMask) = [];
    contigLength = cellfun(@length, croppedBarcodes);

    fprintf('There are %d contigs left after length threshold.\n', length(croppedBarcodes));

    % Rescale all the contigs
    import CA.Core.global_rescale;
    [~, ~, croppedBarcodes] = global_rescale(croppedBarcodes);


    %---ZM ---
    % ZM preparations

    import CBT.UI.prompt_pregen_zero_model;
    [aborted, meanZeroModelFftFreqMags, zeroModelKbpsPerPixel] = prompt_pregen_zero_model();
    if aborted
        fprintf('No valid zero-model was provided\n');
        return;
    end

    % Determine EVD parameters
    numBarcodes = length(croppedBarcodes);
    gumbelCurveMus = zeros(numBarcodes, 1);
    gumbelCurveBetas = zeros(numBarcodes, 1);
    import CBT.ExpComparison.Core.fit_gumbel_with_zero_model;


    % Generate the random barcodes:
    import CBT.RandBarcodeGen.PhaseRandomization.gen_rand_bp_ext_adjusted_zero_model_barcodes;
    refBarcodeLen_pixels = length(refBarcode);
    barcodeKbpsPerPixel = pixelWidth_nm / (1000 * meanBpExt_nm);
    randomBarcodes = gen_rand_bp_ext_adjusted_zero_model_barcodes(numRandBarcodes, refBarcodeLen_pixels, meanZeroModelFftFreqMags, zeroModelKbpsPerPixel, barcodeKbpsPerPixel);

    for nonremovedBarcodeNum = 1:numBarcodes
        barcode = croppedBarcodes{nonremovedBarcodeNum};
        [gumbelCurveMus(nonremovedBarcodeNum), gumbelCurveBetas(nonremovedBarcodeNum)] = fit_gumbel_with_zero_model(...
            barcode, ...
            randomBarcodes, ...
            [], ....
            false, ...
            true, ...
            true);
    end

    %---Main Program---
    % Generate cost matrix
    % TODO: figure out what this is supposed to call...
    [costLists, possibleSites, numPossibleSites, maxLen] = cost_lists_generation(...
        croppedBarcodes,....
        refBarcode,...
        [gumbelCurveMus, gumbelCurveBetas],...
        pThreshold,...
        removePvalue,...
        forcePlacementTF);
    fprintf('Cost lists calculated\n');

    % Remove contigs that can only be not-placed.
    removeMask = numPossibleSites <= 1;
    if any(removeMask)
        croppedBarcodes(removeMask) = [];
        costLists(removeMask) = [];
        contigLength(removeMask) = [];
        possibleSites(removeMask) = [];
        numPossibleSites(removeMask) = [];
    end
    numBarcodes = length(croppedBarcodes);

    % Set all cost values to zero for the sites that are below the threshold
    costListsTemp = cell(numBarcodes,1);
    for nonremovedBarcodeNum = 1:numBarcodes
        costListsTemp{nonremovedBarcodeNum} = zeros(maxLen, 1);
        costListsTemp{nonremovedBarcodeNum}(possibleSites{nonremovedBarcodeNum}) = costLists{nonremovedBarcodeNum}(possibleSites{nonremovedBarcodeNum});
    end



    % Check if there are one-contig states that could be merged into more-contig states.
    import CA.Core.cluster_contigs;
    clustersContigIdxs = cluster_contigs(costListsTemp,forcePlacementTF,clusterThreshold);
    numClusters = length(clustersContigIdxs);

    % Reduce the cost lists so only relevant costs are saved
    for nonremovedBarcodeNum = 1:numBarcodes
        costLists{nonremovedBarcodeNum} = costLists{nonremovedBarcodeNum}(possibleSites{nonremovedBarcodeNum});
    end

    % Merge contig states
    clusterContigStateCounts = cellfun(@length, clustersContigIdxs);
    removalMask = false(length(croppedBarcodes),1);
    nonemptyClusterNum = 1;
    import CA.Core.find_contig_placements_with_brute_force_older;
    for clusterNum = 1:numClusters
        currClusterContigIdxs = clustersContigIdxs{clusterNum};
        if clusterContigStateCounts(clusterNum) < 2
            continue;
        end
        currClusterCostLists = costLists(currClusterContigIdxs);
        currClusterFirstContigNum = currClusterContigIdxs(1);
        [indexListMerged, costListMerged] = find_contig_placements_with_brute_force_older(...
            currClusterCostLists, ...
            possibleSites(currClusterContigIdxs), ...
            numPossibleSites(currClusterContigIdxs), ...
            contigLength(currClusterContigIdxs), ...
            maxLen, ...
            forcePlacementTF, ...
            overlapLim ...
        );
        possibleSites{currClusterFirstContigNum} = indexListMerged;
        numPossibleSites(currClusterFirstContigNum) = length(indexListMerged);
        costLists{currClusterFirstContigNum} = costListMerged;

        currClusterOtherContigNums = currClusterContigIdxs(2:end);
        removalMask(currClusterOtherContigNums) = true;

        fprintf('Cluster %d completed\n', nonemptyClusterNum);
        nonemptyClusterNum = nonemptyClusterNum + 1;
    end
    numPossibleSites(removalMask) = [];
    possibleSites(removalMask) = [];
    costLists(removalMask) = [];

    % Find the, up to, qMax best paths
    import CA.Core.find_q_smallest_columnwise_sums_new_tree;

    % if not(iscell(clustersContigIdxs))
    %     clustersContigIdxs = {clustersContigIdxs};
    % end

    contigOrder = [clustersContigIdxs{:}];
    contigsProvided = sum(clusterContigStateCounts);
    if (contigsProvided == 0)
        fprintf('No contigs provided for contig assembly\n');
    end
    [pathMatrix, ~, actualBestPathNum] = find_q_smallest_columnwise_sums_new_tree(...
        contigOrder, ...
        clusterContigStateCounts, ...
        contigLength, ...
        ...
        costLists, ...
        possibleSites, ...
        numPossibleSites, ...
        ...
        qMax, ...
        maxLen, ...
        overlapLim, ...
        allowOverlap, ...
        forcePlacementTF);
    fprintf('Actual q: %d\n', actualBestPathNum);

    tabTitle = 'Contig Assembly (Older)';
    hTabCA = tsCA.create_tab(tabTitle);
    tsCA.select_tab(hTabCA);
    hPanelCA = uipanel('Parent', hTabCA);
    hAxis = axes('Parent', hPanelCA);
    
    % Plot results
    import CA.UI.plot_contig_placements_older;
    barcodeKbpsPerPixel = pixelWidth_nm / (1000 * meanBpExt_nm);
    plot_contig_placements_older(hAxis, pathMatrix, refBarcode, croppedBarcodes, contigLength, barcodeKbpsPerPixel, contigNames);
end