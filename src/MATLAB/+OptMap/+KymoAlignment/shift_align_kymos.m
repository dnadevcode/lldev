function [channelKymosShiftAligned, amplifiedChannelKymosShiftAligned, approxForegroundMasksShiftAligned, bestChannelsDelays] = shift_align_kymos(flattenedChannelKymos, flattenedFeatureKymos, flattenedApproxForegroundMasks)
    import OptMap.KymoAlignment.xcorr_kymo_align;
    import OptMap.KymoAlignment.analyze_feature_shift_offset;
    import OptMap.KymoAlignment.shift_align_2d_mat_rows;
    import OptMap.KymoAlignment.get_default_feature_detection_settings
    
    featureDetectionSettings = get_default_feature_detection_settings();
    
	numChannels = numel(flattenedChannelKymos);
    channelKymosShiftAligned = cell(numChannels, 1);
    amplifiedChannelKymosShiftAligned = cell(numChannels, 1);
    approxForegroundMasksShiftAligned = cell(numChannels, 1);
    bestChannelsDelays = cell(numChannels, 1);
    for channelNum=1:numChannels
        [...
            channelKymoShiftAligned,...
            amplifiedChannelKymoShiftAligned,...
            approxForegroundMaskShiftAligned,...
            xcorrChannelDelays...
            ] = xcorr_kymo_align(...
                flattenedChannelKymos{channelNum},...
                flattenedFeatureKymos{channelNum},...
                flattenedApproxForegroundMasks{channelNum});

        featureSrcImg = amplifiedChannelKymoShiftAligned;
        featureSrcImgFgMask = approxForegroundMaskShiftAligned;
        numCols = size(featureSrcImg, 2);
        nanfreeCols = arrayfun(@(colIdx) not(any(isnan(featureSrcImg(:, colIdx)))), 1:numCols);
        colStartIdx = find(nanfreeCols, 1, 'first');
        colEndIdx = find(nanfreeCols, 1, 'last');
        featureSrcImg = featureSrcImg(:, colStartIdx:colEndIdx);
        featureSrcImgFgMask = featureSrcImgFgMask(:, colStartIdx:colEndIdx);
        
        [featureOffsets] = analyze_feature_shift_offset(featureSrcImg, featureSrcImgFgMask, featureDetectionSettings);
        additionalFeatureDetectionDelays = -featureOffsets;
        
        channelKymoShiftAligned = shift_align_2d_mat_rows(channelKymoShiftAligned, additionalFeatureDetectionDelays, NaN);
        amplifiedChannelKymoShiftAligned = shift_align_2d_mat_rows(amplifiedChannelKymoShiftAligned, additionalFeatureDetectionDelays, NaN);
        approxForegroundMaskShiftAligned = shift_align_2d_mat_rows(approxForegroundMaskShiftAligned, additionalFeatureDetectionDelays, false);
        bestChannelDelays = xcorrChannelDelays + additionalFeatureDetectionDelays;

        channelKymosShiftAligned{channelNum} = channelKymoShiftAligned;
        amplifiedChannelKymosShiftAligned{channelNum} = amplifiedChannelKymoShiftAligned;
        approxForegroundMasksShiftAligned{channelNum} = approxForegroundMaskShiftAligned;
        bestChannelsDelays{channelNum} = bestChannelDelays;
    end
end