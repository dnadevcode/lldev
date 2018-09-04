function [] = run_dtw_method(warpedSeq, refSeq, useNeighborhoodTF, usePccTF, dist, hAxisCostMatDTW, hAxisAlignment)
    if not(useNeighborhoodTF || usePccTF)
        import SVD.Core.DTW.compute_abs_diff_dtw_cost_mats;
        [costMat, accumCostMat] = compute_abs_diff_dtw_cost_mats(warpedSeq, refSeq);
    else
        if usePccTF
            import SVD.Core.DTW.compute_neg_pcc_dtw_cost_mats;
            [costMat, accumCostMat] = compute_neg_pcc_dtw_cost_mats(warpedSeq, refSeq, dist);
        else
            import SVD.Core.DTW.compute_neighbor_weighted_dtw_cost_mats;
            [costMat, accumCostMat] = compute_neighbor_weighted_dtw_cost_mats(warpedSeq, refSeq, dist);
        end
    end

    import SVD.Core.DTW.find_dtw_path;
    pathCoords = find_dtw_path(accumCostMat);

    costMatNumCols = size(costMat, 2);
    alignmentRefSeqLen = costMatNumCols;
    import SVD.Core.compute_aligned_seq;
    [alignedSeq] = compute_aligned_seq(alignmentRefSeqLen, warpedSeq, pathCoords);

    % Plot the cost matrix together with the warping path
    import SVD.UI.Plot.cost_matrix;
    cost_matrix(hAxisCostMatDTW, costMat, pathCoords);

    % Plot the reference barcode with the aligned barcode warped
    %  according to the DTW path
    import SVD.UI.Plot.alignmentO;
    alignmentO(hAxisAlignment, alignedSeq, refSeq);
    xlim(hAxisAlignment, [0 alignmentRefSeqLen + 5]);
end
