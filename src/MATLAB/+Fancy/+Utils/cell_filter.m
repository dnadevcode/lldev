function [cellOutputVect] = cell_filter(cellInputVect, filterFn)
    %CELL_FILTER - Filters a cell vector using a provided function
    % 
    % Inputs:
    %   cellInputVect
    %     a one-dimensional cell array of values
    %   filterFn
    %     a function that returns false if and only if the value in a cell
    %     does not pass some filter (and true otherwise)
    %
    % Outputs:
    %   cellOutputVect
    %    a one-dimensional cell array of values that pass the filter
    %
    % Authors:
    %   Saair Quaderi
    
    if isempty(cellInputVect)
        cellOutputVect = cellInputVect;
        return;
    end
    validateattributes(cellInputVect, {'cell'}, {'vector'}, 1);
    validateattributes(filterFn, {'function_handle'}, {'scalar'}, 2);
    cellOutputVect = cellInputVect(:);
    cellOutputVect = cellOutputVect(cellfun(filterfn, cellOutputVect));
    sizeIn = size(cellInputVect);
    dimNum = find(sizeIn == max(sizeIn), 1);
    sizeOut = ones(1, max(dimNum, 2));
    sizeOut(dimNum) = numel(cellOutputVect);
    cellOutputVect = reshape(cellOutputVect, sizeOut);
end

