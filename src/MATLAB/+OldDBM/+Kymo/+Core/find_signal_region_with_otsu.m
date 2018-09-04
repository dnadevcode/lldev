function [fgStartIdx, fgEndIdx] = find_signal_region_with_otsu(curveVect, smoothingWindowLen, closableGapLen, numThresholds, minForegroundThreshold)
    % FIND_SIGNAL_REGION_WITH_OTSU - finds the "signal region" of a molecule intensity 
    %	trace (i.e., the part of the curve that corresponds to a molecule and
    %	not to background) using the Otsu method
    %
    % Inputs:
    %   curveVect
    %     the curve vector
    %   smoothingWindowLen
    %     the length of the smoothing window
    %   closableGapLen
    %     the length of gaps to be closed
    %   numThresholds
    %     the number of thresholds to create for multithresh
    %   minForegroundThreshold
    %     the number of threshold
    %
    % Outputs:
    %   fgStartIdx
    %     the index of the approximated left boundary for the molecule
    %   fgEndIdx
    %     the index of the approximated right boundary for the molecule
    %
    % Authors:
    %  Charleston Noble
    %  Saair Quaderi

    if nargin < 2
        smoothingWindowLen = 5;
    else
        validateattributes(smoothingWindowLen, {'numeric'}, {'scalar', 'real', 'nonnegative', 'integer'}, 2);
    end

    if nargin < 3
        closableGapLen = 4;
    else
        validateattributes(closableGapLen, {'numeric'}, {'scalar', 'real', 'nonnegative', 'integer'}, 3);
    end

    if nargin < 4
        numThresholds = 1;
    else
        validateattributes(numThresholds, {'numeric'}, {'scalar', 'real', 'positive', 'integer'}, 4);
    end

    if nargin < 5
        minForegroundThreshold = 1;
    else
        validateattributes(minForegroundThreshold, {'numeric'}, {'scalar', 'real', 'positive', 'integer'}, 5);
    end

    nanMask = isnan(curveVect);
    smoothCurve = curveVect;
    smoothCurve = smooth(smoothCurve, smoothingWindowLen);
    smoothCurve(nanMask) = NaN;
    thresh = multithresh(smoothCurve(~isnan(smoothCurve)), numThresholds);
    quantCurve = curveVect;
    quantCurve(nanMask) = -inf;
    quantCurve = imquantize(quantCurve, thresh) - 1;
    quantCurve = quantCurve >= minForegroundThreshold;

    % Remove molecules which are at the edges of the full signal
    bgRegion = (quantCurve == 0);
    if not(bgRegion(1))
        quantCurve(1:find(bgRegion, 1, 'first')) = 0;
    end
    if not(bgRegion(end))
        quantCurve(max([1, (find(~bgRegion, 1, 'last') + 1)]):end) = 0; 
    end

    % Close gaps smaller than closableGapLen
    quantCurve = imclose(quantCurve(:), ones(1 + closableGapLen, 1));

    % Get the largest region
    regionLabels = bwlabel(quantCurve);
    y = regionprops(logical(quantCurve));
    [~, largestRegionLabel] = max([y.Area]);
    largestRegion = (regionLabels == largestRegionLabel);

    % Find the signal region start and end points
    fgStartIdx = find(largestRegion, 1, 'first');
    fgEndIdx = find(largestRegion, 1, 'last');

    if isempty(fgStartIdx)
       disp('No signal detected using the Otsu method')
    end
end