function [thyCurve_pxRes] = convert_bpRes_to_pxRes(thyCurve_bpRes, meanBpExt_pixels)
    % Convert from bp resolution to pixel resolution
    % with moving average window.
    if nargin < 2
        pxSize = 541.28;
    else
        pxSize = 1/meanBpExt_pixels;
    end
    
    thyCurve_pxRes(floor(length(thyCurve_bpRes)/pxSize)) = 0;
    xtraseq = cat(find(size(thyCurve_bpRes) - 1), ...
                  thyCurve_bpRes(end-round(pxSize):end), ...
                  thyCurve_bpRes, ...
                  thyCurve_bpRes(1:round(2*pxSize)));
    for i = 1:floor(length(thyCurve_bpRes)/pxSize)
        thyCurve_pxRes(i) = mean(xtraseq(floor((i*pxSize)-pxSize+1):floor((i*pxSize)+pxSize)));
    end
end