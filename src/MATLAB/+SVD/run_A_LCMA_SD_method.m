function [] = run_A_LCMA_SD_method(warpedSeq, refSeq, useNeighborhoodTF, usePccTF, dist, bandWidth, lengthParam, lcmaThresholdZeroDist, numBestPaths, hAxisCostMat, hAxisAlignment)
    if not(useNeighborhoodTF || usePccTF)
        import SVD.Core.compute_abs_diff_cost_matrix;
        costMat = compute_abs_diff_cost_matrix(warpedSeq, refSeq);
        lcmaThresholdFactor = 1;
    else
        if usePccTF
            import SVD.Core.compute_neg_pcc_cost_matrix;
            costMat = compute_neg_pcc_cost_matrix(warpedSeq, refSeq, dist);
        else
            import SVD.Core.compute_neighbor_weighted_cost_matrix;
            costMat = compute_neighbor_weighted_cost_matrix(warpedSeq, refSeq, dist);
        end
        lcmaThresholdFactor = (2*dist) + 1; %Autoscale LCMA threshold since the costs in CM increases with 'distance':
    end
    lcmaThreshold = lcmaThresholdFactor * lcmaThresholdZeroDist;

    % repeat the cost matrix to double the length of the cyclical
    %  reference sequence
    costMatExtended = repmat(costMat, [1, 2]);

    import SVD.Core.ALCMASD.compute_alcmasd_accum_cost_mat;
    import SVD.Core.ALCMASD.collect_alcmasd_info;
    import SVD.Core.ALCMASD.find_alcmasd_path;
    accumCostMat = compute_alcmasd_accum_cost_mat(costMatExtended, bandWidth);
    [~, ~, lcmaPixelCount] = collect_alcmasd_info(costMatExtended, accumCostMat, bandWidth, lcmaThreshold, lengthParam);
    [pathCoords, ~] = find_alcmasd_path(costMatExtended, accumCostMat, numBestPaths, lcmaPixelCount, bandWidth);

    % alignmentRefSeqLen = size(costMatExtended, 2);
    alignmentRefSeqLen = length(refSeq);

    import SVD.Core.compute_aligned_seq;
    alignedSeq = compute_aligned_seq(alignmentRefSeqLen, warpedSeq, pathCoords);

    import SVD.UI.Plot.cost_matrix;
    cost_matrix(hAxisCostMat, costMatExtended, pathCoords);

    import SVD.UI.Plot.alignmentO;
    alignmentO(hAxisAlignment, alignedSeq, refSeq);
    xlim(hAxisAlignment, [0, alignmentRefSeqLen +  5]);
end
