function aboveNhoodAvgMask = adaptive_thresh(grayMat, nhoodLen, diffThresh, useMedianTF)
    if nargin < 3
        diffThresh = 0;
    end
    if nargin < 4
        useMedianTF = false;
    end
    if useMedianTF
        filteredMat = medfilt2(grayMat, [nhoodLen, nhoodLen]);
    else % use mean filter
        kernel = ones(nhoodLen, nhoodLen);
        kernel = kernel./sum(kernel(:));
        filteredMat = imfilter(grayMat, kernel, 'replicate');
    end
    aboveNhoodAvgMask = (grayMat - filteredMat) > diffThresh;
end