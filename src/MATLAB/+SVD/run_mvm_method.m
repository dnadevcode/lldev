function [] = run_mvm_method(warpedSeq, refSeq, useNeighborhoodTF, usePccTF, dist, mvmWinWidth, hAxisCostMatMVM, hAxisAlignment)
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

    % repeat the cost matrix to double the length of the cyclical
    %  reference sequence
    costMatExtended = repmat(costMat, [1, 2]);
    refSeqExtended = repmat(refSeq, [2, 1]);

    import SVD.Core.MVM.compute_mvm_path_cost;
    import SVD.Core.MVM.find_mvm_path;
    [pathCostMat, pathMat] = compute_mvm_path_cost(costMatExtended, mvmWinWidth);
    [pathCoords, ~] = find_mvm_path(pathCostMat, pathMat);

    alignmentRefSeqLen = size(costMatExtended, 2);
    import SVD.Core.compute_aligned_seq;
    alignedSeq = compute_aligned_seq(alignmentRefSeqLen, warpedSeq, pathCoords);


    %Plots the cost matrix together with the warping path
    import SVD.UI.Plot.cost_matrix;
    cost_matrix(hAxisCostMatMVM, costMatExtended, pathCoords);

    % Plot the reference barcode with the aligned barcode warped
    %  according to the path
    import SVD.UI.Plot.alignmentO;
    alignmentO(hAxisAlignment, alignedSeq, refSeqExtended, 'Reference Sequence (with repetition)');
    xlim(hAxisAlignment, [0 alignmentRefSeqLen + 40]);
end
