function [idxsForPadding, idxsForRecropping] = get_padding_recropping_idxs_symm_both(aSize, padSize, skipBorderRepeat)
    validateattributes(padSize, {'numeric'}, {'row', 'nonnegative', 'integer'}, 2);
    if nargin < 3
        skipBorderRepeat = 0;
    end
    numDims = length(aSize);
    numDimsP = length(padSize);
    if numDimsP < numDims
        padSize = [padSize, zeros(1, numDims - numDimsP)];
    end
    
    numel(padSize);
    idxsForPadding = cell(1, numDims);
    idxsForRecropping = cell(1, numDims);
    for dimNum = 1:numDims
        aDimLen = aSize(dimNum);
        pDimLen = padSize(dimNum);
        if pDimLen > (aDimLen - skipBorderRepeat)
            error('Array is not large enough for so much symmetric padding in dimension %d', dimNum);
        end
        dimIdxs = 1:aDimLen;
        preSymmDimIdxs = (pDimLen:-1:1) + skipBorderRepeat;
        postSymmDimIdxs = aDimLen - skipBorderRepeat - (0:(pDimLen - 1));
        idxsForPadding{dimNum} = [preSymmDimIdxs, dimIdxs, postSymmDimIdxs];
        idxsForRecropping{dimNum} = dimIdxs + pDimLen;
    end
end