function [costMat, accumCostMat] = compute_neg_pcc_dtw_cost_mats(seq1, seq2, dist)
    %Computes the negative Pearson correlation coefficient matrix 
    %and accumulated cost matrix for two barcodes. Modifies classic DTW 
    %to allow passage through left and right walls. 
    %Input: two barcodes (array of intensity values) and 
    %correlation distance. 
    %Output: cost matrix and accumulated cost matrix. This function 
    %adds 1 to the coefficient such that ____ for computational
    %purposes.
    seqA = seq1;
    seqB = seq2;
    if length(seqB)<length(seqA)
        [seqB, seqA] = deal(seqA,seqB);
    end
    lenA = length(seqA);
    lenB = length(seqB);
    
    costMat = repmat(-1, lenA, lenB);
    accumCostMat = repmat(-1, lenA + 1, lenB + 1);
    accumCostMat(:, 1) = Inf;
    
    distOffsets = (-dist):dist;
    for idxA = 1:lenA
        for idxB = 1:lenB
            if (idxB == 1)
                % TODO: double-check this makes sense, since it seems a bit odd (note from saair)
                accumCostPrevRowPrevCol = accumCostMat(idxA, end); % wrap around to last col
                accumCostSameRowPrevCol = Inf;
            else
                accumCostPrevRowPrevCol = accumCostMat(idxA, idxB);
                accumCostSameRowPrevCol = accumCostMat(idxA + 1, idxB);
            end
            accumCostPrevRowSameCol = accumCostMat(idxA, idxB + 1);
            minPrevCostSum = min([accumCostPrevRowPrevCol, accumCostPrevRowSameCol, accumCostSameRowPrevCol]);
            
            
            rangeIdxsA = idxA + distOffsets;
            rangeIdxsB = idxB + distOffsets;
            rangeIdxsA = 1 + mod(-1 + rangeIdxsA, lenA);
            rangeIdxsB = 1 + mod(-1 + rangeIdxsB, lenB);
            
            pccMat = corrcoef(seqA(rangeIdxsA), seqB(rangeIdxsB));
            pccVal = pccMat(1, 2);
            currCost = 1;
            if not(isnan(pccVal))
                currCost = 1 - pccVal;
            end
            
            costMat(idxA, idxB) = currCost;
            accumCostMat(idxA + 1, idxB + 1) = currCost + minPrevCostSum;
        end
    end
end