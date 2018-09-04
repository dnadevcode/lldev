function [frameKymos] = get_channel_kymos(channelLabeling, frames)
    numChannels = max(channelLabeling);
    frameKymos = cell(numChannels, 1);
    frames = permute(frames, [3, 1, 2]);
    for channelNum=1:numChannels
        frameKymo = frames(:, :, channelLabeling == channelNum);
        frameKymos{channelNum} = frameKymo;
    end
end