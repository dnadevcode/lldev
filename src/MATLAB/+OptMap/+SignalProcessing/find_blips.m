function [blipLabels, nonblipMean, nonblipStd] = find_blips(intensityProfile, maxSigmaNonBlip, minValDistBetweenAdjLocalExtrema)
    % FIND_BLIPS - Finds and labels the "blips" in an intensity profile
    %   curve
    %
    % Inputs:
    %   intensityProfile
    %     the one-dimensional intensity profile on which to find blips
    %   maxSigmaNonBlip
    %     the maximum number of deviations a non-blip robust maxima can be
    %     from the mean non-blip regions' intensity without being
    %     reclassified as a blip maxima
    %   minValDistBetweenAdjLocalExtrema
    %     the minimum absolute distance in value between adjacent extrema
    %     that are classified as "robust"
    %   
    % Outputs:
    %   blipLabels
    %     the labeling of values in the intensity profile
    %     with 0 for pixels that are not part of a blip region
    %     and integer labels for the blip regions where
    %     a blip region is the region between the robust local minima
    %     adjacent to a blip robust maxima
    %     larger blips get lower integer labels starting at 1 and
    %     with intervals of 1
    %   nonblipMean
    %     the mean of the intensity profile in the regions which were not
    %     classified as belonging to a blip
    %   nonblipStd
    %     the standard deviation of the intensity profile in the regions
    %     which were not classified as belonging to a blip
    %
    % Authors:
    %   Saair Quaderi

    import OptMap.SignalProcessing.detect_robust_local_extrema;
    
    [localExtremaIdxs, localExtremaVals] = detect_robust_local_extrema(intensityProfile, minValDistBetweenAdjLocalExtrema, true);
    localExtremaIdxs = localExtremaIdxs(:)';
    localExtremaVals = localExtremaVals(:)';
    maximaValMask = false(size(localExtremaVals));
    % extrema alternates minima, maxima, minima, ...
    maximaValMask(2:2:(end - 1)) = true;
    done = false;
    blipLabels = zeros(size(intensityProfile));
    while not(done)
        nonblipMean = nanmean(intensityProfile(blipLabels == 0));
        nonblipStd = nanstd(intensityProfile(blipLabels == 0));
        extremaNumSigma = (localExtremaVals - nonblipMean)/nonblipStd;
        blipMaxValsMask = maximaValMask & (extremaNumSigma > maxSigmaNonBlip);
        blipMaxIdxs = find(blipMaxValsMask);
        blipMaxVals = localExtremaVals(blipMaxIdxs);
        blipEdgeIdxs = arrayfun(@(blipMaxIdx) localExtremaIdxs(blipMaxIdx - 1):localExtremaIdxs(blipMaxIdx + 1), blipMaxIdxs, 'UniformOutput', false);
        blibIdxs = [blipEdgeIdxs{:}];
        if not(any(blipLabels(blibIdxs) == 0))
            done = true;
        else
            blipRanks = tiedrank(tiedrank(-blipMaxVals) + ((1:numel(blipMaxVals))/numel(blipMaxVals)));
            numRanks = numel(blipRanks);
            blipLabels = zeros(size(intensityProfile));
            for rankNum=1:numRanks
                blipLabels(blipEdgeIdxs{rankNum}) = blipRanks(rankNum);
            end
        end
    end
end