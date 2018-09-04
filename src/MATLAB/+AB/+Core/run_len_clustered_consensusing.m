function [lenClusterNums, clusterMeanCenters, consensusInputs, consensusStructs, cache] = run_len_clustered_consensusing(tsConsensuses, barcodes, bpsPerPx, barcodeDisplayNames, consensusSettings, cache)
    % ------

    tmp_lenRangeFactor = 1.2;
    tmp_barcodeLens_pixels = cellfun(@length, barcodes);
    tmp_numBarcodes = length(tmp_barcodeLens_pixels);

    tmp_bpsPerPx_original = zeros(tmp_numBarcodes, 1) + bpsPerPx;

    if not(isempty(tmp_bpsPerPx_original))
        if not(all(tmp_bpsPerPx_original == tmp_bpsPerPx_original(1)))
            warning('bps/pixel differences are currently being ignored'); % TODO: use bps/pixel information when comparing lengths
        end
    end


    lenClusterNums = zeros(tmp_numBarcodes, 1);
    while any(lenClusterNums == 0)
        tmp_countInLenRange = zeros(tmp_numBarcodes, 1);
        tmp_stdForLensInRange = zeros(tmp_numBarcodes, 1);
        for tmp_barcodeIdx = 1:tmp_numBarcodes
            if lenClusterNums(tmp_barcodeIdx) == 0
                tmp_barcodeLen_pixels = tmp_barcodeLens_pixels(tmp_barcodeIdx);
                tmp_maskInLenRange_pixels = (tmp_barcodeLens_pixels >= (1/tmp_lenRangeFactor).*tmp_barcodeLen_pixels & (tmp_barcodeLens_pixels <= tmp_lenRangeFactor.*tmp_barcodeLen_pixels)) & (lenClusterNums == 0);
                tmp_countInLenRange(tmp_barcodeIdx) = sum(tmp_maskInLenRange_pixels);
                tmp_stdForLensInRange(tmp_barcodeIdx) = std(tmp_barcodeLens_pixels(tmp_maskInLenRange_pixels));
            end
        end
        tmp_maxCountInLenRange = max(tmp_countInLenRange);
        tmp_barcodeIdxsForMaxCountsInLenRanges = find(tmp_countInLenRange == tmp_maxCountInLenRange);
        [~, tmp_mvi] = min(tmp_stdForLensInRange(tmp_barcodeIdxsForMaxCountsInLenRanges));
        tmp_barcodeIdx = tmp_barcodeIdxsForMaxCountsInLenRanges(tmp_mvi);

        tmp_barcodeLen_pixels = tmp_barcodeLens_pixels(tmp_barcodeIdx);
        tmp_maskInLenRange_pixels = (tmp_barcodeLens_pixels >= (1/tmp_lenRangeFactor).*tmp_barcodeLen_pixels & (tmp_barcodeLens_pixels <= tmp_lenRangeFactor.*tmp_barcodeLen_pixels)) & (lenClusterNums == 0);
        lenClusterNums(tmp_maskInLenRange_pixels) = max(lenClusterNums(:)) + 1;
    end
    tmp_numLenClusters = max(lenClusterNums);
    clusterMeanCenters = zeros(tmp_numLenClusters, 1);
    for tmp_lenClusterNum = 1:tmp_numLenClusters
        tmp_lenClusterMask = (lenClusterNums == tmp_lenClusterNum);
        tmp_commonLength_pixels = round(mean(tmp_barcodeLens_pixels(tmp_lenClusterMask)));
        clusterMeanCenters(tmp_lenClusterNum) = tmp_commonLength_pixels;
    end

    consensusInputs = cell(tmp_numLenClusters, 1);
    consensusStructs = cell(tmp_numLenClusters, 1);
    for tmp_lenClusterNum = 1:tmp_numLenClusters
        tmp_lenClusterMask = (lenClusterNums == tmp_lenClusterNum);
        if sum(tmp_lenClusterMask) < 2
            continue;
        end
        tmp_commonLength_pixels = clusterMeanCenters(tmp_lenClusterNum);

        if tmp_commonLength_pixels < 1
            continue;
        end


        import CBT.Consensus.Import.Helper.gen_consensus_inputs_struct;
        consensusInputs{tmp_lenClusterNum} = gen_consensus_inputs_struct(...
            barcodeDisplayNames(tmp_lenClusterMask), ...
            barcodes(tmp_lenClusterMask), ...
            tmp_bpsPerPx_original(tmp_lenClusterMask), ...
            consensusSettings.clusterScoreThresholdNormalized, ...
            tmp_commonLength_pixels, ...
            consensusSettings.preprocessing.stretch.untrustedEdgeLenUnrounded_pixels, ...
            consensusSettings.preprocessing.stretch.pixelWidth_nm ...
        );

        import CBT.Consensus.Core.make_consensus_as_struct;
        [consensusStructs{tmp_lenClusterNum} , cache] = make_consensus_as_struct( ...
            consensusInputs{tmp_lenClusterNum}.barcodes, ...
            consensusInputs{tmp_lenClusterNum}.bitmasks, ...
            consensusInputs{tmp_lenClusterNum}.displayNames,...
            consensusInputs{tmp_lenClusterNum}.otherBarcodeData, ...
            consensusInputs{tmp_lenClusterNum}.clusterScoreThresholdNormalized, ...
            cache ...
        );
    end



    import Fancy.UI.FancyTabs.TabbedScreen;
    import CBT.Consensus.Import.load_consensus_results;
    tmp_isConsensusMask = cellfun(@(x) not(isempty(x)), consensusStructs);
    tmp_cs = consensusStructs(tmp_isConsensusMask);
    for tmp_idx = 1:length(tmp_cs)
        tmp_tabName = sprintf('C %d', tmp_idx);
        tmp_hTabCurrConsensus = tsConsensuses.create_tab(tmp_tabName);
        tmp_hPanelCurrConsensus = uipanel(tmp_hTabCurrConsensus);
        tmp_tsCurrConsensus = TabbedScreen(tmp_hPanelCurrConsensus);
        load_consensus_results(tmp_tsCurrConsensus, tmp_cs{tmp_idx})
    end
end
