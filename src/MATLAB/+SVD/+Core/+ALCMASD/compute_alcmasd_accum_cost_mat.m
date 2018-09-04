function accumCostMat = compute_alcmasd_accum_cost_mat(costMat, bandWidth)
    %Computes accumulated cost matrix for two barcodes.
    %Input: two barcodes (array of intensity values) and a band
    %range parameter that sets the width of the bands to 2*bandWidth+1
    %in units of pixels.
    %Output: accumulated cost matrix.
    %The function also repeats the longest barcode twice.
    numRows = size(costMat, 1);
    numCols = size(costMat, 2);
    numberOfBands = ceil(numCols/(4*bandWidth+2));

    %Boundary Conditions:
    accumCostMat(1:numRows+1, 1:numCols+1) = Inf;
    accumCostMat(1,1:(numCols/2)) = costMat(1,1:(numCols/2));

    %Loop for setting up centres of bands:
    bandCenterColumnIndex = zeros(numberOfBands, 1);
    for bandIdx = 1:numberOfBands
        bandCenterColumnIndex(bandIdx) = 2*bandIdx*bandWidth -bandWidth + bandIdx;
    end

    % Compute ACM loop:
    for bandIdx = 1:numberOfBands
        for rowIdx = 2:numRows+1
            for colIdx = 2:numCols+1
                if numCols < 2*(1 + colIdx - rowIdx)
                    continue;
                end
                tmp = bandCenterColumnIndex(bandIdx) - (1 + colIdx - rowIdx);
                if abs(tmp) > bandWidth
                    continue;
                end
                costValPrevRowPrevCol = costMat(rowIdx - 1, colIdx - 1);
                accumCostValPrevRowPrevCol = accumCostMat(rowIdx - 1, colIdx - 1);
                accumCostValSameRowPrevCol = accumCostMat(rowIdx, colIdx - 1);
                accumCostValPrevRowSameCol = accumCostMat(rowIdx - 1, colIdx);
                accumCostVal = costValPrevRowPrevCol;
                if abs(tmp) == bandWidth
                    switch sign(tmp)
                        case 1
                            accumCostVal = accumCostVal + min([accumCostValPrevRowPrevCol, accumCostValPrevRowSameCol]);
                        case -1
                            accumCostVal = accumCostVal + min([accumCostValPrevRowPrevCol, accumCostValSameRowPrevCol]);
                    end
                else % abs(tmp) < bandWidth
                    accumCostVal = accumCostVal + min([accumCostValPrevRowPrevCol, accumCostValPrevRowSameCol, accumCostValSameRowPrevCol]);
                end
                accumCostMat(rowIdx, colIdx) = accumCostVal;
            end
        end
    end
end