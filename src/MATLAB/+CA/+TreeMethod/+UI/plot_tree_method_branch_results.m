function [] = plot_tree_method_branch_results(ts, dataSampleName, refBarcode, croppedContigBarcodes, kbpsPerPixel, branchIdxs, startMat, flippedMat, contigOrderingsMat, shouldSaveTxtTF)

    % Save the plot to a text file
    for branchIdx = branchIdxs

        % Calculate rescale values
        branchContigOrdering = contigOrderingsMat(branchIdx, :);
        excludedContigsOrderingMask = (branchContigOrdering == 0);
        placedContigsOrderingMask = not(excludedContigsOrderingMask);
        numPlacedContigs = sum(placedContigsOrderingMask);
        placedContigIdxs = branchContigOrdering(1:numPlacedContigs);
        placedContigs = croppedContigBarcodes(placedContigIdxs);

        placedContigs = cellfun(@(placedContig) placedContig(:)', placedContigs, 'UniformOutput', false); % make sure they are all horizontal
        aggregatedPlacedContigVals = horzcat(placedContigs{:}); % concatenate them all
        globalRescaleMean = nanmean(aggregatedPlacedContigVals);
        globalRescaleStd = nanstd(aggregatedPlacedContigVals);

        rescaledContigBarcodes = cellfun(...
            @(contigBarcode) ...
                (contigBarcode - globalRescaleMean)./globalRescaleStd, ...
                croppedContigBarcodes, ...
                'UniformOutput', false);

        % Plot the branch
        tabTitleStr = sprintf('Branch %d', branchIdx);
        hTabCurrBranch = ts.create_tab(tabTitleStr);
        hPanelCurrBranch = uipanel('Parent', hTabCurrBranch);
        hAxisCurrBranch = axes('Parent', hPanelCurrBranch);


        plotTitleStr = sprintf('Branch %d, s-value: %g, coverage %g%%', branchIdx, sTot(branchIdx), coverage(branchIdx));

        refBarcodeLabel = 'Experiment';
        placedContigLabels = cellfun(...
            @(contigIdx) ...
                sprintf('Contig %d', contigIdx), ...
                placedContigIdxs, ...
                'UniformOutput', false);


        startPosIdxs = startMat(branchIdx, :);
        flippedMask = flippedMat(branchIdx, :);
        placedContigsMask = not(startPosIdxs == 0);


        refBarcodeLen_pixels = length(refBarcode);
        % this is sort of "one step back, two steps forward"
        %  recomputing contigPlacementOptionIdxs is silly
        %  but gen_aligned_placement_mats takes it as input
        %  to produce the mat
        contigPlacementOptionIdxs = zeros(size(placedContigsMask)) + (2 * refBarcodeLen_pixels) + 1;
        contigPlacementOptionIdxs(placedContigsMask) = startPosIdxs(placedContigsMask) + flippedMask.*refBarcodeLen_pixels;

        import CA.Core.gen_aligned_placement_mats;
        [~, refContigPlacementValsMat] = gen_aligned_placement_mats(...
            refBarcodeLen_pixels, ...
            rescaledContigBarcodes(placedContigIdxs), ...
            contigPlacementOptionIdxs(placedContigsMask));

        import CA.UI.plot_contig_placements;
        plot_contig_placements(...
            hAxisCurrBranch, ...
            plotTitleStr, ...
            refBarcode, ...
            refContigPlacementValsMat, ...
            kbpsPerPixel, ...
            refBarcodeLabel, ...
            placedContigLabels ...
        );

        if shouldSaveTxtTF
            import CA.Export.export_contig_placements_txt;
            export_contig_placements_txt(dataSampleName, refBarcode, refContigPlacementValsMat, kbpsPerPixel);
        end
    end
end