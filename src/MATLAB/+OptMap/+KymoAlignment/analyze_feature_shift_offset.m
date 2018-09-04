function [ shiftOffsets ] = analyze_feature_shift_offset(kymoImg, kymoFgApprox, featureDetectionSettings)
    % ANALYZE_FEATURE_SHIFT_OFFSET
    import OptMap.KymoAlignment.find_features;
    
    [featurePathMat, featurePathMeans, featurePathOffsets, featurePathDists] = find_features(kymoImg, featureDetectionSettings);
    numFeatures = size(featurePathOffsets, 1);
    dissimilarityMat = inf(numFeatures);
    for featureNumA=1:numFeatures
        featureA = featurePathOffsets(featureNumA, :);
        for featureNumB=1:numFeatures
            featureB = featurePathOffsets(featureNumB, :);
            dissimilarityMat(featureNumA, featureNumB) = norm(featureA - featureB);
        end
    end
    
    dissimilarityVarianceFactor = 1.0;
    dissimilarityCutoff = sqrt(size(featurePathOffsets, 2) * median(var(dissimilarityVarianceFactor*featurePathOffsets')));
    Z = linkage(dissimilarityMat, 'complete');
    offsetClusters = cluster(Z, 'cutoff', dissimilarityCutoff, 'criterion', 'distance');
    mainOffsetCluster = mode(offsetClusters);
    mainClusterFeatures = (offsetClusters == mainOffsetCluster);
    mainFeatureOffsets = featurePathOffsets(mainClusterFeatures, :);
    shiftOffsets = median(mainFeatureOffsets, 1);
    shiftOffsets = shiftOffsets(:);
end

