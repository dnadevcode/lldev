function [ output ] = process_movie_TA( sets )
    %process_movie
    %
    % :param sets: input parameter.
    % :returns: output
    
    % written by Albertas Dvirnas

    %% We begin by code inspired by Hemant Kumar 
    %for gettabStructing from movies to
    % kymographs
    
    %% load movie. Later make this loop through all movies
	idx = 1;

    % we can load movie using autobarcoding function, which is meant for 
    % speed up things with inputs etc
    import AB.Processing.load_movie;
    movie =  load_movie(sets.moviefilefold{idx},sets.filenames{idx});  
    % make it into 3d array. Alternatively, keep working with the cell
    % struct
    movie = cat(3, movie{:});
    
    %% Correct movie for dead pixels
    import  ELD.Processing.correct_movies;
    [correctedMovie,movieMask] = correct_movies(movie,sets);
    
    
    %% Rotate movie
    import ELD.Processing.rotate_movie;
	[rotatedMovie,rotatedAmp, movieAngle] = rotate_movie(correctedMovie,sets);
    
    %% Detect channels. Only one per movie. Could change this with allowing user to select how many?
    import  ELD.Processing.extract_channels;
	channelLabeling = {extract_channels(rotatedAmp,sets)};
    
     %% Extract channel kymo/ background
     import  ELD.Processing.extract_kymos;
     [kymo, background, kymosAmp] =  extract_kymos(channelLabeling,rotatedMovie,rotatedAmp );

    %% Matched filter
    import ELD.Processing.match_filter_kymo;
    [filteredKymo] =  match_filter_kymo(kymo{1},sets);

    %% Detect peaks
    import ELD.TAStuff.run_peak_detection_TA;
    [peakMap, peakLocs ,peakHeightsMap , peakHeights ]  = run_peak_detection_TA( filteredKymo, background{1}, sets);


    %% Assign peak labels to each peak
    tic
    import ELD.TAStuff.assign_peak_labels_TA;
    [noOfRawFeatures peakLabels] = assign_peak_labels_TA(peakLocs,peakHeights,sets.localFluctuationWindow,sets.allowCrossings);
    noOfRawFeatures

    %% Generate features
    import ELD.TAStuff.generate_features_from_peak_labels
     [ featureRows , featureCols ] = ...
        generate_features_from_peak_labels( noOfRawFeatures, peakLocs, peakLabels , sets.minConC);
    toc
    noOfFeatures = length(featureRows)

%% Some plotting of features

    % Plot peak map 
    figure
    peakHPlot=peakHeightsMap/max(max(peakHeightsMap));
    imshow(peakHPlot, 'InitialMagnification', 100)
    hold on

    % Plot features 
    import ELD.TAStuff.distinguishable_colors;
    colorsDist = distinguishable_colors(noOfFeatures);
    for featureIdx = 1:noOfFeatures
       plot(featureCols{featureIdx},featureRows{featureIdx},'-','Color',colorsDist(featureIdx,:),'Linewidth',1)
    end
    hold off

%%
    %     %% Calculate feature distances
    %     % TA: 'features' below is not in the same format as above?
    %     % Above 'features' is a cell, below a matrix???
    %     % 
    %     tic
    %     import  ELD.Processing.calculate_feature_distances;
    %     [fD,fdV,fO] = calculate_feature_distances(features, sets);
    %     toc
    %     
    % 
        %--------- FORMAT RESULTS
    import Fancy.Utils.var2struct;
    % Hack to save all variables in current workspace as fields in a struct
    vars_to_save = feval(@(allvars) allvars(~strncmp('tmp_', allvars, 4)), who());
    output = eval(['var2struct(', strjoin(vars_to_save, ', '),');']);
	assignin('base','output',output)
    
    % TODO: go clean up merge_features function

%     % Compute optimal estimator distance
%     [optimalEstimatorDistance,~,~,~,numFeatures] = ELD.Labelling.merge_features(featuresCellArray_ordered,fD,fdV,fO,numel(featuresCellArray_ordered),sets);
% 
%     fD = diag(optimalEstimatorDistance,1);
%     [fD, sorting] = ELD.Labelling.order_features_by_dists(fD);
%     fdV = fdV(sorting,sorting);
% 
%     for featureI = 1:numFeatures-1
%         [fdVs(featureI), ~, ~] = graphshortestpath(sparse(fdV),featureI,featureI+1);
%     end
% 
%     featuresCellArray_processed = featuresCellArray_ordered(sorting);

    % TODO: add function to compute a score for map vs map comparison
    
    % TODO: try super-resolving features

    
    
end

