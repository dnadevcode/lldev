function [lineRgbData] = get_rgb_data(dispImg, colStartIdx, rowStartIdx, colEndIdx, rowEndIdx, layerOffsets)
    if nargin < 6
        layerOffsets = 0;
    end
    xyCoords = [colStartIdx, rowStartIdx; colEndIdx, rowEndIdx];
    dist = sqrt(sum(diff(xyCoords, 1).^2, 2));
    xyStep = diff(xyCoords, 1)./dist;
    layerOffsetStep = fliplr(xyStep) .* [1, -1];

    numSamples = round(dist);
    numOffsets = length(layerOffsets);
    numChannels = size(dispImg, 3);
    lineRgbData = zeros(numSamples, numOffsets, numChannels);
    import AB.Core.img_profile;
    for offsetIdx = 1:numOffsets
        layerOffset = layerOffsets(offsetIdx);
        for channelNum = 1:numChannels
            [interpVals, ~] = img_profile(dispImg(:, :, channelNum), xyCoords + layerOffsetStep.*layerOffset, numSamples);
            lineRgbData(:, offsetIdx, channelNum) = interpVals;
        end
    end
end