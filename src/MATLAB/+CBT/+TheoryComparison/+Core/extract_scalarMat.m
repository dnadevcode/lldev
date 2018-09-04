function scalarMat = extract_scalarMat(cellStructMat, fieldName, missingValValue)
    import CBT.TheoryComparison.Core.cell_mat_2_mat;

    hasFieldValue = cellfun(@(currStruct) (isstruct(currStruct) && isscalar(currStruct) && isfield(currStruct, fieldName)), cellStructMat);
    cellArrayOfFieldValues = cell(size(cellStructMat));
    cellArrayOfFieldValues(hasFieldValue) =  cellfun(@(currStruct) currStruct.(fieldName), cellStructMat(hasFieldValue), 'UniformOutput', false);

    scalarMat = cell_mat_2_mat(cellArrayOfFieldValues, missingValValue);
end