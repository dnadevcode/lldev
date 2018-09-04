function [segData, idxRangesMat] = segment_nonadj_data(idxs,  data)
    validateattributes(idxs, {'numeric'}, {'increasing', 'nonnegative', 'integer'}, 1);
    if not(isempty(idxs))
        validateattributes(idxs, {'numeric'}, {'vector'}, 1);
    end
    idxs = idxs(:)';
    if nargin < 2
        data = 1:max(idxs);
    else
        if max(idxs) < numel(data)
            error('Indices must not exceed data index range');
        end
        validateattributes(data, {'cell', 'numeric'}, {}, 2);
    end
    idxRangesMat = [idxs(diff([-inf, idxs]) ~= 1); idxs(diff([idxs,inf]) ~= 1)]';
    numRanges = size(idxRangesMat, 1);

    if iscell(data)
        segData = arrayfun(...
            @(rangeNum) ...
                data{idxRangesMat(rangeNum,1):idxRangesMat(rangeNum,2)}, ...
            (1:numRanges)', ...
            'UniformOutput', false);
    else
        segData = arrayfun(...
            @(rangeNum) ...
                data(idxRangesMat(rangeNum,1):idxRangesMat(rangeNum,2)), ...
            (1:numRanges)', ...
            'UniformOutput', false);
    end
end