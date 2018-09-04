function [alignedKymo, alignedBlurredKymo, featurePathColIdx, stretchFactorsMat] = wpalign_helper(...
        kymo, ...
        blurredKymo, ...
        leftX, ...
        rightX, ...
        maxFeatureMovementPerRow_pixels, ...
        unstretchedSideWidth, ...
        barrierVal ...
    )
    % wpalign_helper
    %
    % Inputs:
    %	kymo
    %	  the kymograph
    %	blurredKymo
    %	  the filtered version of the kymograph
    %	leftX
    %	  the left boundary for alignment
    %	rightX
    %	  the right boundary for alignment
    %	maxFeatureMovementPerRow_pixels
    %	  the maximum n
    %	unstretchedSideWidth
    %	  how many pixels from leftX and rightX are not included in
    %      the stretching process
    %  barrierVal
    %    how high a feature path cost/dist is permissible (before it is
    %    ignored)
    % 
    % Outputs:
    %   alignedKymo
    %	  the kymograph after the round of alignment
    %   blurredKymo
    %	  the blurred kymograph after the round of alignment
    %   featurePathColIdx
    % 	  the column index for the feature that was found
    %     (NaN if non was found that passed the barrier)
    %   stretchFactorsMat
    %	  array of the stretch factor of each pixel in the kymograph
    %
    % Authors: 
    %	Charleston Noble
    %   Saair Quaderi (clean up, removal of globals; stretch factors)

    stretchFactorsMat = ones(size(kymo));
    featurePathColIdx = NaN;
    if (rightX - leftX + 1) <= 25
        alignedKymo = kymo;
        alignedBlurredKymo = blurredKymo;
        return;
    end

    partialBlurredKymo = blurredKymo(:, leftX:rightX);

    [numPartialRows, numPartialCols] = size(partialBlurredKymo);

    maxFeatureMovementTotal_pixels = maxFeatureMovementPerRow_pixels * numPartialRows;
    if numPartialCols < maxFeatureMovementTotal_pixels
        import OptMap.KymoAlignment.WPAlign.find_single_feature;
        [featurePathsVect, lowestFeaturePathCost] = find_single_feature(partialBlurredKymo, maxFeatureMovementPerRow_pixels, barrierVal);

    else
        numWindows = ceil(numPartialCols / maxFeatureMovementTotal_pixels) * 2 - 1;
        nbr = ceil(numPartialCols / maxFeatureMovementTotal_pixels);
        windowLen = round(ceil(numPartialCols / nbr)/2);

        featurePathsMat = zeros(numPartialRows,numWindows);
        featurePathCosts = zeros(1,numWindows);

        partialsPartialBlurredKymo = cell(numWindows,1);
        windowStartArr = 1 + (((1:numWindows) - 1) * windowLen);
        windowEndArr =  max(numPartialCols, 1 + ((1:numWindows) * windowLen));


        for windowNum = 1:numWindows
            windowStartCol = windowStartArr(windowNum);
            windowEndCol = windowEndArr(windowNum);

            partialsPartialBlurredKymo{windowNum} = partialBlurredKymo(:, windowStartCol:windowEndCol);
        end

        import OptMap.KymoAlignment.WPAlign.find_single_feature;
        for windowNum = 1:numWindows
            windowStartCol = windowStartArr(windowNum);

            [featurePathsVect, dist] = find_single_feature(partialsPartialBlurredKymo{windowNum}, maxFeatureMovementPerRow_pixels, barrierVal);
            featurePathsVect = featurePathsVect + windowStartCol;
            featurePathsMat(:, windowNum) = featurePathsVect;
            featurePathCosts(windowNum) = dist;     
        end

        [featurePathCosts, sortOrder] = sort(featurePathCosts);
        featurePathsMat = featurePathsMat(:, sortOrder);

        featurePathsVect = featurePathsMat(:, 1);
        lowestFeaturePathCost = featurePathCosts(1);
    end
    
    alignedKymo = kymo;
    alignedBlurredKymo = blurredKymo;
    barrierPassingFeatureFound = lowestFeaturePathCost < barrierVal;
    if not(barrierPassingFeatureFound)
        return;
    end

    
    colIdxs = (leftX - unstretchedSideWidth):(rightX + unstretchedSideWidth);
    pathsColIdxs = featurePathsVect + unstretchedSideWidth;
    
    imgSz = size(alignedKymo(:, colIdxs));
    import OptMap.KymoAlignment.compute_stretch_factors;
    stretchFactorsMat(:, colIdxs) = compute_stretch_factors(pathsColIdxs, imgSz);

    import OptMap.KymoAlignment.apply_horizontal_stretching;
    alignedKymo(:, colIdxs) = apply_horizontal_stretching(alignedKymo(:, colIdxs), stretchFactorsMat(:, colIdxs));
    alignedBlurredKymo(:, colIdxs) = apply_horizontal_stretching(alignedBlurredKymo(:, colIdxs), stretchFactorsMat(:, colIdxs));

    featurePathColIdx = round(mean(featurePathsVect)) + leftX - 1;
end