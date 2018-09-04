function [channelKymoAligned, amplifiedChannelKymoAligned, approxFgMaskAligned, bestDelays] = xcorr_kymo_align(channelKymo, amplifiedChannelKymo, approxFgMask)
    import SignalRegistration.XcorrAlign.norm_xcorr;
    
    if nargin < 2
        amplifiedChannelKymo = channelKymo;
    end
    
    if nargin < 3
        approxFgMask = true(size(amplifiedChannelKymo));
    end
    
    channelKymoAligned = channelKymo;
    amplifiedChannelKymoAligned = amplifiedChannelKymo;
    approxFgMaskAligned = approxFgMask;
    nanSubval = min([0; channelKymoAligned(:); amplifiedChannelKymoAligned(:)]) - 1;
    numFrames = size(channelKymoAligned, 1);
    kymoWidth = size(channelKymoAligned, 2);
    channelKymoAligned = padarray(channelKymoAligned, [0, kymoWidth], nanSubval);
    amplifiedChannelKymoAligned = padarray(amplifiedChannelKymoAligned, [0, kymoWidth], nanSubval);
    approxFgMaskAligned = padarray(approxFgMaskAligned, [0, kymoWidth], false);
    b = amplifiedChannelKymoAligned(1,:);
    bitmaskB = approxFgMaskAligned(1,:);
    circularA = false;
    circularB = false;
    maxDelay = 5;
    bestDelays = zeros(numFrames, 1);
    for frameNum = 2:numFrames
        a = b;
        bitmaskA = bitmaskB;
        b = amplifiedChannelKymoAligned(frameNum,:);
        bitmaskB = approxFgMaskAligned(frameNum,:);
        [xcorrs, coverageLens, delays] = norm_xcorr(a, b, bitmaskA, bitmaskB, circularA, circularB, maxDelay);
        scores = xcorrs(:).*sqrt(coverageLens(:));
        [~, bestDelayIdx] = max(scores);
        bestDelay = delays(bestDelayIdx);
        bestDelays(frameNum) = bestDelays(frameNum - 1) + bestDelay;
        channelKymoAligned(frameNum:end,:) = circshift(channelKymoAligned(frameNum:end,:),bestDelay,2);
        amplifiedChannelKymoAligned(frameNum:end,:) = circshift(amplifiedChannelKymoAligned(frameNum:end,:),bestDelay,2);
        approxFgMaskAligned(frameNum:end,:) = circshift(approxFgMaskAligned(frameNum:end,:),bestDelay,2);
        b = amplifiedChannelKymoAligned(frameNum,:);
        bitmaskB = approxFgMaskAligned(frameNum,:);
    end
    idxs = max(channelKymoAligned) > 0;
    channelKymoAligned = channelKymoAligned(:,idxs);
    amplifiedChannelKymoAligned = amplifiedChannelKymoAligned(:,idxs);
    approxFgMaskAligned = approxFgMaskAligned(:,idxs);
    channelKymoAligned(channelKymoAligned == nanSubval) = NaN;
    amplifiedChannelKymoAligned(amplifiedChannelKymoAligned == nanSubval) = NaN;
end