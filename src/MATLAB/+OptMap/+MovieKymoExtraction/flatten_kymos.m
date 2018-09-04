function [flattenedChannelKymos, flattenedAmplifiedChannelKymos, flattenedApproxForegroundMasks] = flatten_kymos(channelKymos, amplifiedChannelKymos, approxForegroundMasks, foregroundDetectionStruct)
    flattenedChannelKymos = cellfun(@(channelKymo) mean(channelKymo, 3), channelKymos, 'UniformOutput', false);
    flattenedAmplifiedChannelKymos = cellfun(@(amplifiedChannelKymo) mean(amplifiedChannelKymo, 3), amplifiedChannelKymos, 'UniformOutput', false);
    flattenedApproxForegroundMasks = cellfun(@(approxForegroundMask) sum(approxForegroundMask, 3) > foregroundDetectionStruct.flatteningNumLayersThreshold, approxForegroundMasks, 'UniformOutput', false);
end