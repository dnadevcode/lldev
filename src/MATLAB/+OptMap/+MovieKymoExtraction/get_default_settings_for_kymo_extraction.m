function [defaultSettings] = get_default_settings_for_kymo_extraction()
    defaultSettings.version = '0.1.0';

    %--------- IMPORT MOVIE
    import Microscopy.Import.import_grayscale_tiff_video;
    defaultSettings.import.maxNumFramesToLoad = inf; % this was once 850, but unclear why
    defaultSettings.fn.import_movie = @import_grayscale_tiff_video;
    
    %--------- CLEAN MOVIE OF OUTLIERS
    defaultSettings.cleanup.skipCleanup = false;
    defaultSettings.cleanup.skipCleanupReport = false;
    
    %--------- CROP MOVIE
	import Microscopy.UI.RegionSelection.select_movie_region_prompt;
    defaultSettings.cropping.skipCropping = false;
    defaultSettings.fn.select_movie_region = @select_movie_region_prompt;
    
    %--------- FILTER MOVIE FOR FOREGROUND & CHANNEL DETECTON
    defaultSettings.amplification.amplificationKernel = struct(...
        'spacialNeighborhoodRadius', 2.0,...
        'temporalNeighborhoodHalfLen', 2.0,...
        'spacialDimDistanceWarpingPower', 2.0,...
        'temporalDimDistanceWarpingPower', 2.0);
    
    %--------- ROTATE MOVIE
    defaultSettings.rotation.useFramewiseConsensus = false;
    defaultSettings.rotation.numAngleCandidates = 2^6;
    
    %--------- DETECT CHANNELS
    defaultSettings.channelDetection.channelWidthPx = uint8(3);
    defaultSettings.channelDetection.channelGapWidthPx = uint8(3);
    % FOR PROCESS_CB_MOVIE
    % potential channels can be found via blip detection
    %   on a cross profile of intensities perpendicular to angle
    %   of parallel channels, but that blip detection relies on
    %   detecting robust local extrema and looking for statistical
    %   anomolies in the extrema amplitudes
    % minAdjLocalExtremaDistRelToRange should be a value from 0 to 1
    %   (on the lower end) representing the minimal intensity difference
    %   for values at adjacent extrema to be considered a robust local
    %   extrema (if the profile signal was normalized to have a minimum
    %    value of 0 and a maximal value of 1)
    % maxSigmaNonBlip specifies how many deviations away a potential
    %    blip must be from the other non-blip bumps in the profile signal
    %    to be detected as a blip (outlier stats are determined recursively
    %    with exclusion of detected outliers until convergence on the
    %    outlying blips detected)
    defaultSettings.channelDetection.maxSigmaNonBlip = 3.0;
    defaultSettings.channelDetection.minAdjLocalExtremaDistRelToRange = 0.05;
    
    %--------- PROFILE NOISY BACKGROUND
    defaultSettings.backgroundProfile.confidenceAlpha = 0.05; % Within upper/lower bounds with 95% confidence
    
    %--------- DETECT MULTILAYER CHANNEL KYMO FOREGROUNDS
    defaultSettings.foregroundSeparation.numSigmaThreshold = 3;
    defaultSettings.foregroundSeparation.imopenStrelNhood = true(1, 3);
    defaultSettings.foregroundSeparation.imcloseStrelNhood = true(1, 3);
    defaultSettings.foregroundSeparation.flatteningNumLayersThreshold = uint8(ceil(defaultSettings.channelDetection.channelWidthPx/2));
end