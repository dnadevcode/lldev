function cellVector = cellify_arr_dims(arr, cellifyDimIdxs)
    validateattributes(cellifyDimIdxs, {'numeric'}, {'row', 'increasing', 'positive', 'integer', '<=', ndims(arr)}, 2);
    dimDists = arrayfun(@(dimlen) dimlen, size(arr)', 'UniformOutput', false);
    dimDists(cellifyDimIdxs) = cellfun(@(dimlen) ones(1, dimlen), dimDists(cellifyDimIdxs), 'UniformOutput', false);
    cellVector = mat2cell(arr, dimDists{:});
end