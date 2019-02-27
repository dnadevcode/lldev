function [featuresCellArray_processed, fD,fdVs ] = extract_labels( kymo,bcgr,sets )
    % function extract_labels
    
    % input: kymo and sets
    % output: featuresCellArray_processed, fD,fdV
    
    % written by: Albertas Dvirnas
    
    % run peak detection
    [ peakMap ] = ELD.Labelling.run_peak_detection( kymo,bcgr );
     peakGraph = ELD.Labelling.generate_peak_graph(kymo,sets.localFluctuationWindow,peakMap);

    % remove peaks using global Otsu
   % peakStrongMap = ELD.Labelling.remove_weak_peaks(kymo,peakMap);
    
    % remove sparse peaks
   % peakStrongMap =  ELD.Labelling.remove_sparse_peaks( peakStrongMap, sets );
    
    %Create a peak graph
  %  peakGraph = ELD.Labelling.generate_peak_graph(kymo,sets.localFluctuationWindow,peakStrongMap);
    
    % Find connected components in the peak graph
    featuresArray = ELD.Labelling.process_peak_graph(peakGraph,sets.minConC);%Process the connected components and save only those whose size is greater than the threshold.

    % Organize features. What does this do exactly?
    [ featuresCellArray_ordered, peakTable] =  ELD.Labelling.organize_features(featuresArray,size(kymo));

    % Calculate feature distances
    [fD,fdV,fO] = ELD.Labelling.calculate_feature_distances(featuresCellArray_ordered,1:length(featuresCellArray_ordered),[],sets.minVertOverlap );

    % Compute optimal estimator distance
    [optimalEstimatorDistance,~,~,~,numFeatures] = ELD.Labelling.merge_features(featuresCellArray_ordered,fD,fdV,fO,numel(featuresCellArray_ordered),sets);

    fD = diag(optimalEstimatorDistance,1);
    [fD, sorting] = ELD.Labelling.order_features_by_dists(fD);
    fdV = fdV(sorting,sorting);

    for featureI = 1:numFeatures-1
        [fdVs(featureI), ~, ~] = graphshortestpath(sparse(fdV),featureI,featureI+1);
    end

    featuresCellArray_processed = featuresCellArray_ordered(sorting);


end

