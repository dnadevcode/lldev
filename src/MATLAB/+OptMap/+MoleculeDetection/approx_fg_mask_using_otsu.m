function [valsArrForegroundMask, fgThreshold, thresholdsArr] = approx_fg_mask_using_otsu(valArr, numThresholds, minNumThresholdsFgShouldPass)
    % APPROX_FG_MASK_USING_OTSU - approximates foregrou

    validateattributes(valArr, {'numeric'}, {}, 1);
    validateattributes(numThresholds, {'numeric'}, {'scalar', 'positive', 'integer'}, 2);
    validateattributes(minNumThresholdsFgShouldPass, {'numeric'}, {'scalar', 'integer', '<=', numThresholds}, 3);

    thresholdsArr = multithresh(valArr, numThresholds);
    fgThreshold = -inf;
    if minNumThresholdsFgShouldPass > 0
        thresholdsArr(minNumThresholdsFgShouldPass);
    end
    valsArrForegroundMask = valArr >= fgThreshold;
end