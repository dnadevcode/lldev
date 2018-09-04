function [] = run_lap_method(warpedSeq, refSeq, useNeighborhoodTF, usePccTF, dist, hAxisCostMat, hAxisAlignment)
    if not(useNeighborhoodTF || usePccTF)
        import SVD.Core.compute_abs_diff_cost_matrix;
        costMat = compute_abs_diff_cost_matrix(warpedSeq, refSeq);
    else
        if usePccTF
            import SVD.Core.compute_neg_pcc_cost_matrix;
            costMat = compute_neg_pcc_cost_matrix(warpedSeq, refSeq, dist);
        else
            import SVD.Core.compute_neighbor_weighted_cost_matrix;
            costMat = compute_neighbor_weighted_cost_matrix(warpedSeq, refSeq, dist);
        end
    end

    alignmentRefSeqLen = size(costMat, 2);
    import SVD.Core.LAP.find_lap_mapping;
    yxCoords = find_lap_mapping(costMat);


    import SVD.Core.LAP.compute_lap_aligned_seq;
    alignedSeq = compute_lap_aligned_seq(alignmentRefSeqLen, warpedSeq, yxCoords);

    import SVD.UI.Plot.cost_matrix;
    cost_matrix(hAxisCostMat, costMat, yxCoords);

    import SVD.UI.Plot.alignmentO;
    alignmentO(hAxisAlignment, alignedSeq, refSeq);
    xlim(hAxisAlignment, [0, alignmentRefSeqLen + 10]);
end
