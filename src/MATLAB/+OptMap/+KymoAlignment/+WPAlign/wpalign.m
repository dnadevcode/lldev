function [alignedKymo, stretchFactorsMat] = wpalign(unalignedKymo)
    % WPALIGN - recursively aligns a kymograph (see the WPAlign paper)
    %
    % Inputs:
    %	unalignedKymo
    %	  the unaligned kymograph (the only input to the initial fcn call)
    %
    % Outputs: 
    %	alignedKymo
    %	  the aligned kymograph is output in the last step
    %   stretchFactorsMat
    %	  array of the stretch factor of each pixel in the kymograph
    %
    % Authors: 
    %	Charleston Noble
    %   Saair Quaderi (clean up, removal of globals; stretch factors)

    
    
    
    unstretchedSideWidth = 5;
    
    
    %  featureHalfWidth
    %	  how many pixels from a found feature the left/right
    %      boundaries in subsequent recursive calls to this function
    featureHalfWidth = 5;
    
    barrierVal = 10000;
    maxFeatureMovementPerRow_pixels = 3;

    smoothWindow = 10;
    import OptMap.KymoAlignment.apply_gaussian_blur;
    blurredKymo = apply_gaussian_blur(unalignedKymo, smoothWindow);
    
    leftColIdx = 1 + unstretchedSideWidth;
    rightColIdx = size(unalignedKymo, 2) - unstretchedSideWidth;
    
    featureCount = 0;
    next_ranges = [leftColIdx, rightColIdx];
    
    alignedKymo = unalignedKymo;
    alignedBlurredKymo = blurredKymo;
    stretchFactorsMat = ones(size(unalignedKymo));
    import OptMap.KymoAlignment.WPAlign.wpalign_helper;
    while size(next_ranges, 1) > 0
        leftColIdx = next_ranges(1, 1);
        rightColIdx = next_ranges(1, 2);
        next_ranges(1, :) = [];
        [alignedKymo, alignedBlurredKymo, featurePathColIdx, currStretchFactorsMat] = wpalign_helper(...
            alignedKymo, ...
            alignedBlurredKymo, ...
            leftColIdx, ...
            rightColIdx, ...
            maxFeatureMovementPerRow_pixels, ...
            unstretchedSideWidth, ...
            barrierVal ...
        );
        stretchFactorsMat = stretchFactorsMat .* currStretchFactorsMat;

        if not(isnan(featurePathColIdx))
            featureCount = featureCount + 1;
        else
            left_range = [leftColIdx, (featurePathColIdx - featureHalfWidth)];
            right_range = [(featurePathColIdx + featureHalfWidth), rightColIdx];
            next_ranges = [next_ranges; left_range; right_range];
        end
    end
end