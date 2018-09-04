function [cellOutputArray] = cell_map(cellInputArray, mappingFn)
    % CELL_MAP - Maps a cell array using a provided mapping function
    % 
    % Inputs:
    %  cellInputArray
    %    a cell array of values
    %  mappingFn
    %    a function that maps an input value to an output value
    %
    % Outputs:
    %  cellOutputArray
    %    a one-dimensional cell array of values mapping to the input
    %
    % Authors:
    %   Saair Quaderi
    
    validateattributes(cellInputArray, {'cell'}, {}, 1);
    validateattributes(mappingFn, {'function_handle'}, {'scalar'}, 2);
    cellOutputArray = cellfun(mappingFn, cellInputArray, 'UniformOutput', false);
end

