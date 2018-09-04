function [movieProcessingResultsStruct] = process_dot_movie(srcTiffFilepath, settings)
    % similar to process_cb_movie but without general fluorescent staining 
    %  of molecules (with quantum dot labeling of genes instead)
	
    %#ok<*ASGLU>
    %#ok<*STRNU>
    % Variables and struct fields not obviously used are still
    %  outputted in struct through who-eval hackery
     
    import OptMap.MovieKymoExtraction.get_default_settings_for_kymo_extraction;
    import Fancy.Utils.merge_structs;
    defaultSettings = get_default_settings_for_kymo_extraction();
    defaultSettings.rotation.numAngleCandidates = 2^8;
    if nargin < 2
        settings = defaultSettings;
    else
        settings = merge_structs(defaultSettings, settings);
    end
     
    settings.import.srcTiffFilepath = srcTiffFilepath;
    clear srcTiffFilepath defaultSettings;
    
    %--------- IMPORT MOVIE, CLEAN UP OUTLIERS, NORMALIZE, & CROP
    disp('Importing movie...');
    tmp_fn_import_movie = settings.fn.import_movie;
    [tmp_movie.raw, tmp_movie.valueRange, tmp_movie.loadedFrameNums, tmp_movie.srcImfInfo] = tmp_fn_import_movie(settings.import.srcTiffFilepath, settings.import.maxNumFramesToLoad);
    tmp_movie.raw = permute(tmp_movie.raw, [1 2 4 3]);
    if length(size(tmp_movie.raw)) < 3
        warning('Not a movie with multiple frames, returning empty array');
        movieProcessingResultsStruct = [];
        return;
    end
    
    %--------- CLEAN MOVIE OF OUTLIERS
    import Microscopy.cleanup_movie;
    if not(settings.cleanup.skipCleanup)
        disp('Cleaning out movie outliers...');
        [tmp_movie.cleaned, details.cleanup] = cleanup_movie(tmp_movie.raw);
        
        if not(settings.cleanup.skipCleanupReport)
            if height(details.cleanup.outliers.table) > 0
                fprintf(' Outlier cutoff value: %g\n', details.cleanup.outlierCutoff);
                fprintf(' Outliers/Total: %d/%d\n', height(details.cleanup.outliers.table),  numel(tmp_movie.cleanedScaled));
                disp(details.cleanup.outliers.table);
            end
        end
    else
        tmp_movie.cleaned = tmp_movie.raw;
    end
    
    
    %--------- NORMALIZE MOVIE
    disp('Normalizing movie...');
    tmp_movie_max = max(tmp_movie.cleaned(:));
    tmp_movie_min = min(tmp_movie.cleaned(:));
    details.normalization.unnormalized_max = tmp_movie_max * tmp_movie.valueRange(2);
    details.normalization.unnormalized_min = tmp_movie_min * tmp_movie.valueRange(1);
    tmp_movie.cleanedScaled = (tmp_movie.cleaned - tmp_movie_min)/(tmp_movie_max - tmp_movie_min);
    
    
    %--------- CROP MOVIE
    if not(settings.cropping.skipCropping)
        disp('Prompting for selection of movie region to crop to...');
        tmp_fn_select_movie_region = settings.fn.select_movie_region;
        [tmp_movie.cleanedScaledCropped, details.cropping] = tmp_fn_select_movie_region(tmp_movie.cleanedScaled);
    else
        tmp_movie.cleanedScaledCropped = tmp_movie.cleanedScaled;
    end
    
    
    %--------- FILTER MOVIE FOR FOREGROUND & CHANNEL DETECTON
    % Generate kernel
    import Microscopy.generate_amplification_kernel;
    tmp_amplificationKernel_neighborhoodCutoffDistByDim = [settings.amplification.amplificationKernel.spacialNeighborhoodRadius.*ones(1, 2), settings.amplification.amplificationKernel.temporalNeighborhoodHalfLen]; % distance cutoffs in each dimension
    tmp_amplificationKernel_distWarpingPowers = [settings.amplification.amplificationKernel.spacialDimDistanceWarpingPower.*ones(1, 2), settings.amplification.amplificationKernel.temporalDimDistanceWarpingPower]; % how much the distances should be warped
    [tmp_amplificationKernel] = generate_amplification_kernel(tmp_amplificationKernel_neighborhoodCutoffDistByDim, tmp_amplificationKernel_distWarpingPowers);
    
    % Amplify with kernel
    import Microscopy.amplify_molecules;
    disp('Generating amplified movie for foreground detection...');
    [tmp_movie.cleanedScaledCroppedAmplified] = amplify_molecules(tmp_movie.cleanedScaledCropped, tmp_amplificationKernel);
    
    
    %--------- ROTATE MOVIE
    % 180 degree range [-90, 90) divided evenly into 64 angles
    %  (angles are 2.8125 degrees apart from one another)
    import OptMap.MovieKymoExtraction.get_movie_angle;
    disp('Determining movie nanochannel angle...');
    
    tmp_rotation_num_angle_candidates = settings.rotation.numAngleCandidates;
    [details.rotation.movieAngle] = get_movie_angle(tmp_movie.cleanedScaledCroppedAmplified, tmp_rotation_num_angle_candidates, settings.rotation.useFramewiseConsensus);
    
    details.rotation.movieAngle = mod(details.rotation.movieAngle, 360);
    tmp_details.rotation.ninetyDegRotations = round(details.rotation.movieAngle/90);
    tmp_details.rotation.finetunedRotation = details.rotation.movieAngle - tmp_details.rotation.ninetyDegRotations*90;
    tmp_details.rotation.ninetyDegRotations = mod(tmp_details.rotation.ninetyDegRotations, 4);

    data.movie.processed = rot90(tmp_movie.cleanedScaledCropped, tmp_details.rotation.ninetyDegRotations);
    data.movie.processedAmplified = rot90(tmp_movie.cleanedScaledCroppedAmplified, tmp_details.rotation.ninetyDegRotations);

    if tmp_details.rotation.finetunedRotation ~= 0
        warning('Movie data is being rotated via bilinear interpolation');
        data.movie.processed = imrotate(data.movie.processed, tmp_details.rotation.finetunedRotation, 'bilinear', 'crop');
        data.movie.processedAmplified = imrotate(data.movie.processedAmplified, tmp_details.rotation.finetunedRotation, 'bilinear', 'crop');
    end
    
    
    %--------- DETECT CHANNELS
    disp('Detecting pseudo-nanochannels...');
    
    tmp_maxChannelIdxDiff = round((double(settings.channelDetection.channelWidthPx) - 1)/2);
    tmp_channelIdxDiffs = -tmp_maxChannelIdxDiff:tmp_maxChannelIdxDiff;
    
    [~, tmp_colIdx] = max(mean(sum(data.movie.processedAmplified), 3));
    details.channelDetection.channelLabeling = zeros(size(data.movie.processed, 2), 1);
    details.channelDetection.channelLabeling(tmp_colIdx + tmp_channelIdxDiffs) = 1;
    
    
    %--------- EXTRACT MULTILAYER CHANNEL KYMO
	import OptMap.MovieKymoExtraction.get_channel_kymos;
    disp('Extracting multi-layer nanochannel kymographs...');
    [data.multilayer_kymo.channels] = get_channel_kymos(details.channelDetection.channelLabeling, data.movie.processed);
    [data.multilayer_kymo.channelsAmplified] = get_channel_kymos(details.channelDetection.channelLabeling, data.movie.processedAmplified);
    
    
    %--------- PROFILE NOISY BACKGROUND
	import OptMap.MovieKymoExtraction.generate_background_profile;
    disp('Profiling background...');
    details.foregroundSeparation.backgroundSamplingColIdxs = ~imdilate(details.channelDetection.channelLabeling(:) > 0, ones(3*2 + 1,1));
    tmp_foregroundSeparation_backgroundSample = data.movie.processedAmplified(:, details.foregroundSeparation.backgroundSamplingColIdxs, :);
    tmp_foregroundSeparation_backgroundSample = tmp_foregroundSeparation_backgroundSample(:);
    details.foregroundSeparation.backgroundProfile = generate_background_profile(tmp_foregroundSeparation_backgroundSample, settings.backgroundProfile.confidenceAlpha);
    
    
    %--------- DETECT MULTILAYER CHANNEL KYMO FOREGROUNDS
	import OptMap.MoleculeDetection.approx_fg_mask_using_context_stats;
    disp('Generating multi-layer nanochannel foreground mask kymographs...');
    data.multilayer_kymo.channelsForegroundMasks = cellfun(@(amplifiedChannelKymo) approx_fg_mask_using_context_stats(amplifiedChannelKymo, settings.foregroundSeparation, details.foregroundSeparation.backgroundProfile), data.multilayer_kymo.channelsAmplified, 'UniformOutput', false);


    %--------- FLATTEN MULTILAYER CHANNEL KYMOS
	import OptMap.MovieKymoExtraction.flatten_kymos;
    disp('Generating flattened multi-layer kymographs...');
    [data.flat_kymo.channelKymos, data.flat_kymo.channelsAmplified, data.flat_kymo.channelsForegroundMasks] = flatten_kymos(data.multilayer_kymo.channels, data.multilayer_kymo.channelsAmplified, data.multilayer_kymo.channelsForegroundMasks, settings.foregroundSeparation);
    
    
    %--------- FORMAT RESULTS
    import Fancy.Utils.var2struct;
    % Hack to save all variables in current workspace as fields in a struct
    vars_to_save = feval(@(allvars) allvars(~strncmp('tmp_', allvars, 4)), who());
    movieProcessingResultsStruct = eval(['var2struct(', strjoin(vars_to_save, ', '),');']);
end