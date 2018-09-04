function numMat = cell_mat_2_mat(cellMat, missingValuesValue)
    noValuedCells = cellfun(@isempty, cellMat);       %# Find indices of empty cells
    cellMat(noValuedCells) = {missingValuesValue}; %# Fill empty cells with missingValuesValue
    numMat = cell2mat(cellMat);
end