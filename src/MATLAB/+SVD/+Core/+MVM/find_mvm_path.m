function [pathCoords, totalCost] = find_mvm_path(pathCostMat, pathMat)
    %Backracks the best alignment path in the pathMatrix.
    %Input: pathcost and pathMatrix matrices from the MVM
    %algorithm.
    %Output: pathMatrix coordinates of the best alignment path in an array of
    %[x-index y-index] values. The total cost of the path.
    numRows = size(pathCostMat, 1);
    pathCoords = NaN(numRows, 2);
    rowIdx = numRows;
    [totalCost, colIdx] = min(pathCostMat(rowIdx, :));
    pathCoords(rowIdx, 1:2) = [rowIdx, colIdx];
    for rowIdx = (rowIdx - 1):-1:1
        colIdx = pathMat(rowIdx + 1, colIdx);
        pathCoords(rowIdx, 1:2) = [rowIdx, colIdx];
    end
end


