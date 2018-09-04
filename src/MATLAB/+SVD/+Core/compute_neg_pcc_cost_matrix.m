function costMat = compute_neg_pcc_cost_matrix(seq1, seq2, dist)
    %Computes the negative Pearson correlation coefficient matrix 
    %for two barcodes.
    %Input: two barcodes (array of intensity values) and 
    %correlation distance. 
    %Output: cost matrix 
    %This function adds 1 to the coefficient such for 
    %computational purposes
    
    if length(seq2) < length(seq1)
        [seqLonger, seqShorter] = deal(seq1, seq2);
    else
        [seqLonger, seqShorter] = deal(seq2, seq1);
    end
    refSeq = seqLonger;
    warpedSeq = seqShorter;
    warpedSeqLen = length(warpedSeq);
    refSeqLen = length(refSeq);
    
    costMat = repmat(-1, warpedSeqLen, refSeqLen);
    
    distOffsetsVect = (-dist):dist;
    for warpedSeqIdx = 1:length(warpedSeq)
        for refSeqIdx = 1:length(refSeqExtended)
            
            warpedSeqIdxRange = distOffsetsVect + warpedSeqIdx;
            refSeqIdxRange = distOffsetsVect + refSeqIdx;
            
            warpedSeqIdxRange = 1 + mod(-1 + warpedSeqIdxRange, warpedSeqLen);
            refSeqIdxRange = 1 + mod(-1 + refSeqIdxRange, refSeqLen);
            
            pearsonMatrix = corrcoef( ...
                warpedSeq(warpedSeqIdxRange), ...
                refSeq(refSeqIdxRange));
            
            tmpCost = 1;
            if not(isnan(pearsonMatrix(1,2)))
                tmpCost = tmpCost - pearsonMatrix(1, 2);
            end
            costMat(warpedSeqIdx, refSeqIdx) = tmpCost;
        end
    end
end