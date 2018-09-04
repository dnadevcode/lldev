function [costMat, accumCostMat] = compute_abs_diff_dtw_cost_mats(seq1, seq2)
    %Computes cost matrix and accumulated cost matrix for two
    %barcodes. Modifies classic DTW to allow passage through left
    %and right walls (cyclic)
    %Input: two sequences (array of intensity values).
    %Output: cost matrix and accumulated cost matrix.
    seqA = seq1;
    seqB = seq2;
    if length(seqB) < length(seqA)
        [seqB, seqA] = deal(seqA,seqB);
    end
    lenA = length(seqA);
    lenB = length(seqB);

    costMat = zeros(lenA, lenB);
    accumCostMat = zeros(lenA + 1, lenB + 1);
    accumCostMat(2:end, 1) = Inf;

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
            minPrevCostSum = min([accumCostPrevRowPrevCol, accumCostSameRowPrevCol, accumCostPrevRowSameCol]);

            currCost = abs(seqA(idxA) - seqB(idxB));

            costMat(idxA, idxB) = currCost;
            accumCostMat(idxA + 1, idxB + 1) = currCost + minPrevCostSum;
        end
    end
end
