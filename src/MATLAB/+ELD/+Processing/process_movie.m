function [ output ] = process_movie( sets )
    %process_movie
    %
    % :param sets: input parameter.
    % :returns: output
    
    % written by Albertas Dvirnas

    %% We begin by code inspired by Hemant Kumar 
    %for getting from movies to
    % kymographs
    
    %% load movie. Later make this loop through all movies
	%idx = 1;
    pkmap =cell(1,length(sets.moviefilefold));
    for idx=1:length(sets.moviefilefold)
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

         %% Preprocess kymograph - matched filter
         %https://se.mathworks.com/help/phased/ug/matched-filtering.html
         import ELD.Processing.match_filter_kymo;
        [filteredKymo] =  match_filter_kymo(kymo{1},sets);

        %% run peak detection
        
        tic
        import ELD.Labelling.run_peak_detection;
        [peakMap, peakLocs ,peakHeightsMap , peakHeights ] = run_peak_detection( filteredKymo,background{1}, sets);
        toc

        
        %% Create a peak graph and extract features
%         xD = 1000;
%         tic
%         import  ELD.Processing.assign_peak_labels;
%         [noOfFeatures, peakFeatureLabels] = assign_peak_labels(peakLocs(1:xD), peakHeights(1:xD) , sets.localFluctuationWindow);
%         toc
%         
%         import ELD.Processing.generate_features_from_peak_labels
%          [ featureRows , featureCols ] = generate_features_from_peak_labels( noOfRawFeatures, peakLocs(1:xD), peakLabels(1:xD) , sets.minConC);
%         toc
%          noOfFeatures = length(featureRows);
        
%         
%         tic
%         import  ELD.Processing.generate_peak_graph;
%         [edges,features, mx, connectedComp] = generate_peak_graph([xD, size(filteredKymo,2)], peaklocs(1:xD),sets.localFluctuationWindow,sets.minConC);
%         toc
%         idd = 740;
%         connectedComp(idd,connectedComp(idd,:)~=0)
%         peakFeatureLabels{idd}
%         tTemp = zeros(1,1000);
%         for idd=1:1000
%             tTemp(idd) = isequal(connectedComp(idd,connectedComp(idd,:)~=0),peakFeatureLabels{idd});
%         end
        %%
        tic
        import  ELD.Processing.assign_peak_labels;
        [noOfFeatures, peakFeatureLabels] = assign_peak_labels(peakLocs, peakHeights , sets.localFluctuationWindow);
        
        import ELD.Processing.generate_features_from_peak_labels
         [ features ] = ...
            generate_features_from_peak_labels( noOfRawFeatures, peakLocs, peakLabels , sets.minConC);
        toc
%         noOfFeatures = length(features)
        
%           figure
%         peakHPlot=peakHeightsMap/max(max(peakHeightsMap));
%         imshow(peakHPlot, 'InitialMagnification', 100)
%         hold on
%                 % Plot features 
%         import ELD.Export.distinguishable_colors;
%         colorsDist = distinguishable_colors(noOfFeatures);
%         for featureIdx = 1:noOfFeatures
%            plot(features{featureIdx}(2,:),features{featureIdx}(1,:),'-','Color',colorsDist(featureIdx,:),'Linewidth',1)
%         end
%         hold off
%     

        %% Calculate feature distances
        tic
        import  ELD.Processing.calculate_feature_distances;
        [fD,fdV,fO] = calculate_feature_distances(features, sets);
        toc

        %% Calculate time series from feature
        import ELD.Processing.generate_feature_time_series;
        tS = generate_feature_time_series(filteredKymo, features,sets );

        pkmap{idx} = peakMap;
    end
   
  
    % TODO: add function to compute a score for map vs map comparison
    
    % TODO: try super-resolving features

 %% Import sequences
 theorySeq = fastaread(sets.thrfilenames{1});
 
 % find sequence matches
import ELT.Core.find_sequence_matches;
[bindingExpectedMask, numberOfBindings] = find_sequence_matches(sets.targetSequence, theorySeq.Sequence,1);

    
    
end

