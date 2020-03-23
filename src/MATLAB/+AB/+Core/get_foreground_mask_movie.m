function [fgMaskMovB] = get_foreground_mask_movie(movieRotCyc, foregroundMaskingSettings)
    maxAmpDist = foregroundMaskingSettings.maxAmpDist;
    
    nanMask = isnan(movieRotCyc);
    nonnanMask = ~nanMask;
    nonnanMeanVal = mean(movieRotCyc(nonnanMask));
    nonnanMeanStd = std(movieRotCyc(nonnanMask));
    numRandVals = sum(nanMask(:));
    
    currRng = rng(); % so that current rng state can be restored
    rng(rng(0, 'twister'));  % temporarily set to produce predictable pseudorandom values for reproducibility
    randVals = randn([numRandVals, 1]) .* nonnanMeanStd + nonnanMeanVal;
    rng(currRng); % restore rng state
    
    movieRotCycAmp = movieRotCyc;
    movieRotCycAmp(nanMask) = randVals;
    
    import AB.Processing.amplify_movie;
    szInit = size(movieRotCycAmp);
    [movieRotCycAmp] = amplify_movie(movieRotCycAmp, maxAmpDist);
    
    invalidPadSz = (szInit - size(movieRotCycAmp))./2; % since movieRotCycAmp is restricted to valid region
    
    % substract the mean
    a = movieRotCycAmp - mean(movieRotCycAmp(:));
    
    if length(size(a)) > 3
        colSignalVect = sum(permute(sum(a, 1), [4 2 3 1]));
    else
        colSignalVect = sum(sum(a,3), 1); % hacky fix for AB_Run to work
    end
    
    maxSigmaNonBlip = foregroundMaskingSettings.maxSigmaNonBlip;
    minValDistBetweenAdjLocalExtrema = foregroundMaskingSettings.minValDistBetweenAdjLocalExtrema;
    
%         import OptMap.SignalProcessing.detect_robust_local_extrema;
%     
%     [localExtremaIdxs, localExtremaVals] = detect_robust_local_extrema(intensityProfile, minValDistBetweenAdjLocalExtrema, true);

    
    % find blips - blips are peaks in the intensity profile
    import OptMap.SignalProcessing.find_blips;
    sigChannelsMask = find_blips(colSignalVect, maxSigmaNonBlip, minValDistBetweenAdjLocalExtrema);
    
    %% 4.0.0 If no signal channels detected, take only channels with local blips (as opposed to
    % those with robust local blips)
    
    if sum(sigChannelsMask)==0
        sigChannelsMask =  colSignalVect > 0;
    else
        sigChannelsMask = (sigChannelsMask > 0) & (colSignalVect > 0);
    end
    sigChannelsMask = padarray(sigChannelsMask, [0, invalidPadSz(2)], false, 'both');
    
    nonnanSigChannelVals = padarray(movieRotCycAmp, invalidPadSz, NaN, 'both');
    nonnanSigChannelVals(nanMask) = NaN;
    nonnanSigChannelVals = nonnanSigChannelVals(:, sigChannelsMask, :, :);
    nonnanSigChannelVals = nonnanSigChannelVals(not(isnan(nonnanSigChannelVals)));
    
    % threshold for the foreground (regions with blip)
    fgThreshA1 = graythresh(nonnanSigChannelVals); %TODO: make this potential point of failure more robust
    % background values are where signal is less than threshold
    bgValsA1 = nonnanSigChannelVals(nonnanSigChannelVals < fgThreshA1);
    % second thresh, mean + 3 std
    fgThreshA2 = mean(bgValsA1) + 3*std(bgValsA1);
    % the combined is the minimum of the two (so we include more signal
    % pixels, choosing max would include less signal pixels)
    fgThreshB = min(fgThreshA1, fgThreshA2);
    fgMaskMovB = nanMask | padarray(movieRotCycAmp >= fgThreshB, invalidPadSz, false, 'both');
%     fgMaskMov = fgMaskMovB;
end