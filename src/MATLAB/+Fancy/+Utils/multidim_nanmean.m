function [arrOut] = multidim_nanmean(arrIn, dimsToReduce)
    % MULTIDIM_NANMEAN - reduces each of the sets of values found in the
    % array along the specified dimensions into their nanmean
    %
    % e.g. if the size of arrIn is AxBxCxD and dims to reduce are 2 & 4,
    %   the output size will be Ax1xCx1 and all values across dimensions 2
    %   & 4 will be treated as a set (column vector) for each combination
    %   of coordinate indices associated with the remaining dimensions and
    %   then run through the nanmeaning function so that each set produces
    %   a singular value for the output matrix
    %
    % Inputs:
    %  arrIn
    %    the input array
    %  dimsToReduce
    %    a row vector containing the dimensions which are to be averaged
    %
    % Outputs:
    %  arrOut
    %     the output array with the nanmeans
    %
    % Authors:
    %    Saair Quaderi
    
    import Fancy.Utils.multidim_reduce;
    
    fnReduceFirstDim = @(arr) mean(arr, 1, 'omitnan');
    [arrOut] = multidim_reduce(arrIn, dimsToReduce, fnReduceFirstDim);
end