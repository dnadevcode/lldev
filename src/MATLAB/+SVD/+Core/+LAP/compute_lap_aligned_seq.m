function [alignedSeq] = compute_lap_aligned_seq(alignmentRefSeqLen, warpedSeq, yxCoords)
    alignedSeq = NaN(alignmentRefSeqLen, 1);
    yCoords = yxCoords(:, 1);
    xCoords = yxCoords(:, 2);
    alignedSeq(xCoords) = warpedSeq(yCoords);
end