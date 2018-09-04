function [featurePathMat, featurePathMeans, featurePathOffsets, featurePathDists] = find_features(unalignedKymo, featureDetectionSettings)
    % FIND_FEATURES - find features in an image
    %
    % Inputs: 
    %	unalignedKymo
    %     an unaligned kymograph where values in rows represent intensities
    %      at spacial positions within a timeframe (ordered by row number)
    %   numFeatures
    %      number of features we wish to find
    % Outputs: 
    %	featurePaths
    %     the feature paths
    
    import OptMap.KymoAlignment.apply_feature_detection_filter;
    import OptMap.KymoAlignment.find_k_features;
    
    typicalFeatureHalfwidth = featureDetectionSettings.typicalFeatureHalfwidth;
    maxMovementPx = featureDetectionSettings.maxMovementPx;
    fn_apply_gaussian_filter = featureDetectionSettings.fn.apply_gaussian_filter;
    maxNumFeatures = featureDetectionSettings.maxNumFeatures;
    
    filtrationSettings = featureDetectionSettings.filtrationSettings;
    
    kymoSize = size(unalignedKymo);
    alignedKymo = unalignedKymo;
    alignedKymoSmooth = fn_apply_gaussian_filter(alignedKymo);

    numRows = kymoSize(1);
    numCols = kymoSize(2);

    rangeContraction = [1, -1]*typicalFeatureHalfwidth;

    rangeRegular = [1, numCols];
    rangeContracted = rangeRegular + rangeContraction;

    rangeContractedColIdxs = rangeContracted(1):rangeContracted(2);

    alignedImgSmoothCropped = alignedKymoSmooth(:, rangeContractedColIdxs);

    filteredImg = apply_feature_detection_filter(alignedImgSmoothCropped, filtrationSettings);
%     maxAbsVal = max(abs(filteredImg(:)));
%     filteredImgColored = cat(3, -filteredImg.*(filteredImg < 0)/maxAbsVal, filteredImg.*(filteredImg > 0)/maxAbsVal, zeros(size(filteredImg)));
%     imshow(filteredImgColored);
    
    foundFeatures = find_k_features(filteredImg, maxMovementPx, typicalFeatureHalfwidth, maxNumFeatures);
    foundFeatures(:,1) = cellfun(@(ffPath) ffPath  + (rangeContracted(1) - 1), foundFeatures(:, 1), 'UniformOutput', false);
    featurePathDists = [foundFeatures{:, 2}];
    numFoundFeatures = size(foundFeatures,1);
    featurePathMat = zeros(kymoSize);
    featurePathMeans = nan(numFoundFeatures, 1);
    featurePathOffsets = zeros(numFoundFeatures, numRows);
    for featuresFoundNum = 1:numFoundFeatures
        featurePath = foundFeatures{featuresFoundNum,1};
        featurePathMean = ceil(mean(featurePath));
        featurePathMat(sub2ind(kymoSize, (1:numRows)', featurePath)) = featuresFoundNum;
        featurePathMeans(featuresFoundNum) = featurePathMean;
        featurePathOffsets(featuresFoundNum, :) = featurePath - featurePathMeans(featuresFoundNum);
    end
end
