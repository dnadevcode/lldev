function [channelLabeling] = get_channel_indices(channelProfileSignal, channelWidthPx, channelGapWidthPx, maxSigmaNonBlip, minValDistBetweenAdjLocalExtrema)
    import OptMap.SignalProcessing.find_blips;
    [blipLabels, nonblipMean, nonblipSigma] = find_blips(channelProfileSignal, maxSigmaNonBlip, minValDistBetweenAdjLocalExtrema);
    
    sigmaCurve = (channelProfileSignal - nonblipMean)/nonblipSigma;
    blipLabels2 = blipLabels(:);
    blipLabels2(sigmaCurve < maxSigmaNonBlip) = 0;
    
    channelPxHalfWidthMinusHalf = (double(channelWidthPx) - 1)/2;
    signalLen = numel(channelProfileSignal);
    channelLabeling = nan(size(channelProfileSignal));
    channelSignalSmooth = smooth(channelProfileSignal, 1 + 2*channelPxHalfWidthMinusHalf);
    numLabels = max(blipLabels2);
    for labelNum=1:numLabels
        [~, pkLoc] = max(channelSignalSmooth(:).*(blipLabels2 == labelNum));
        idxLocsArea = max(min(pkLoc + ((-(channelGapWidthPx + channelPxHalfWidthMinusHalf)):1:(channelPxHalfWidthMinusHalf)), signalLen), 1);
        idxLocsChannelPxs = max(min(pkLoc + ((-channelPxHalfWidthMinusHalf):1:channelPxHalfWidthMinusHalf), signalLen), 1);
        
        tmpMask = nan(signalLen, 1);
        tmpMask(idxLocsArea) = 0;
        tmpMask(idxLocsChannelPxs) = labelNum;
        replaceValMask = ~isnan(tmpMask);
        if all(isnan(channelLabeling(replaceValMask)))
            channelLabeling(replaceValMask) = tmpMask(replaceValMask);
        end
    end
    channelLabeling(isnan(channelLabeling)) = 0;
end