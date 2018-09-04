function [alignedSeq] = compute_aligned_seq(alignmentRefSeqLen, warpedSeq, pathCoords)
    warpedSeqIdxs = pathCoords(:, 1);
    alignedSeqIdxs = pathCoords(:, 2);
    nonnanCoords = not(isnan(warpedSeqIdxs) | isnan(alignedSeqIdxs));
    warpedSeqIdxs = warpedSeqIdxs(nonnanCoords);
    alignedSeqIdxs = alignedSeqIdxs(nonnanCoords);
    alignedSeqIdxs = 1 + mod(-1 + alignedSeqIdxs, alignmentRefSeqLen);
    alignedSeq = NaN(alignmentRefSeqLen, 1);
    alignedSeq(alignedSeqIdxs) = warpedSeq(warpedSeqIdxs);
end