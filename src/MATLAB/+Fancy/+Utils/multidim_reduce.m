function [arrOut] = multidim_reduce(arrIn, dimsToReduce, fnReduceFirstDim)
    % MULTIDIM_REDUCE - reduces each of the sets of values found in the
    % array along the specified dimensions into a single value using the
    % function provided
    %
    % e.g. if the size of arrIn is AxBxCxD and dims to reduce are 2 & 4,
    %   the output size will be Ax1xCx1 and all values across dimensions 2
    %   & 4 will be treated as a set (column vector) for each combination
    %   of coordinate indices associated with the remaining dimensions and
    %   then run through the reduction function so that each set produces
    %   a singular value for the output matrix
    %
    % See also: https://en.wikipedia.org/wiki/Fold_(higher-order_function)
    %
    % Inputs:
    %  arrIn
    %    the input array
    %  dimsToReduce
    %    a row vector containing the dimensions which are to be reduced
    %  fnReduceFirstDim
    %    a function that takes a column vector as input and produces a
    %    scalar value
    %
    % Outputs:
    %  arrOut
    %     the output array
    %
    % Authors:
    %    Saair Quaderi
    
    validateattributes(dimsToReduce, {'numeric'}, {'positive', 'integer', 'increasing', 'row'}, 2);
    validateattributes(fnReduceFirstDim, {'function_handle'}, {'scalar'}, 3);
    arrInSz = size(arrIn);
    arrInSzPadded = ones(1, max(dimsToReduce));
    arrInSzPadded(1:length(arrInSz)) = arrInSz;
    
    remainingDims = setdiff(1:length(arrInSzPadded), dimsToReduce); % get the dimensions which arent being reduced
    arrOut = permute(arrIn, [dimsToReduce, remainingDims]); % reorder dimensions to have the dimsToReduce dimensions first
    arrOut = reshape(arrOut, [prod(arrInSzPadded(dimsToReduce)), arrInSzPadded(remainingDims)]); % collapse all the dimsToReduce dimensions into the first dimension
    arrOut = fnReduceFirstDim(arrOut); % run the reduction function for the first dimension
    arrOutSz = arrInSzPadded;
    arrOutSz(dimsToReduce) = 1;
    arrOut = reshape(arrOut, arrOutSz); % reshape the output to make up for the dimension rearangements
end