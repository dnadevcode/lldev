function [ filteredImg ] = apply_feature_detection_filter( inputImg, filtrationSettings)
% APPLY_FEATURE_DETECTION_FILTER
    fn_apply_LoG_filter = filtrationSettings.fn.apply_LoG_filter;
    filteredImg = fn_apply_LoG_filter(inputImg);
    posValsMask = filteredImg > 0;
    negValsMask = filteredImg < 0;
    posVals = filteredImg(posValsMask);
    negVals = filteredImg(negValsMask);
    if not(isempty(posVals))
        filteredImg(posValsMask) = posVals ./ max(posVals);
    end
    if not(isempty(negVals))
        filteredImg(negValsMask) = negVals ./ abs(min(negVals));
    end
end

