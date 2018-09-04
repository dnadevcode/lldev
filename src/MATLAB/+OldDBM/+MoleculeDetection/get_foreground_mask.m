function [imgFgMask] = get_foreground_mask(rotatedAmplifiedMovie, fgMaskingSettings)
    
    % First, segment the image.
    theshFrame = mean(rotatedAmplifiedMovie, 3);
    thresholds = multithresh(theshFrame(:), fgMaskingSettings.numThresholds);
    imgQuantizedRegions = imquantize(theshFrame, thresholds);
    imgFgMask = imgQuantizedRegions > 1 + fgMaskingSettings.minThresholdsForegroundMustPass;

    % Save only the largest connected components.
    cc = bwconncomp(imgFgMask);
    numPixels = cellfun(@numel, cc.PixelIdxList);
    idxs = find(numPixels < fgMaskingSettings.minFgCCPixels);
    for detectedChannelNum = 1:length(idxs)
        imgFgMask(cc.PixelIdxList{idxs(detectedChannelNum)}) = false;
    end
end