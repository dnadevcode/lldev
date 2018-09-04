function [lcmaSegmentsCellArr, lcmaPixelCoordsCellArr, lcmaPixelCount] = collect_alcmasd_info(costMatrix, accumulatedCostMatrix, bandWidth, thresholdParam, lengthParam)
    %Stores the LCMA information in cell arrays where each cell
    %holds info for a different band. The output 'lcmaSegmentsCellArr' is just the
    %lcma segments for the different bands collected in a cell
    %array. 'lcmaPixelCoordsCellArr' holds their ACM coordinates.

    import SVD.Core.ALCMASD.find_alcmasd_paths;
    import SVD.Core.ALCMASD.detect_lcma_segments;
    [pathsCellArray, costsCellArray, numberOfBands] = find_alcmasd_paths(costMatrix, accumulatedCostMatrix, bandWidth);

    %Collect LCMA information in cell arrays:
    lcmaSegmentsCellArr = cell([numberOfBands 1]);
    lcmaPixelCoordsCellArr = cell([numberOfBands 1]);
    lcmaPixelCount = zeros(numberOfBands, 1);
    for k = 1:numberOfBands
        currLcmaSegments = detect_lcma_segments(costsCellArray{k}, thresholdParam, lengthParam);
        numCurrLcmaSegments = size(currLcmaSegments, 1);
        
        lcmaSegmentsCellArr{k} = currLcmaSegments;
        currPath = pathsCellArray{k};
        if isempty(currLcmaSegments)
            lcmaPixelCoordsCellArr{k} = [NaN NaN];
        else
            pixelCoordIdx = 1;
            currPixelCount = 0;
            currLcmaPixelCoords = NaN(1 + numCurrLcmaSegments, 2);
            for currSegmentIdx = 1:numCurrLcmaSegments
                currSegment = currLcmaSegments(currSegmentIdx,:);
                currPathStartIdx = currSegment(1);
                currPathEndIdx = currSegment(2);
                currPathSegment = currPath(currPathStartIdx:currPathEndIdx, :);
                currLcmaPixelCoords(pixelCoordIdx + (1:length(currPathSegment)), :) = currPathSegment;
                pixelCoordIdx = pixelCoordIdx + length(currPathSegment);
                currPixelCount = currPixelCount + (currPathEndIdx - currPathStartIdx); %TODO: (from saair) this really looks like it might be off by one, double-check this
            end
            
            lcmaPixelCount(k) = currPixelCount;
            lcmaPixelCoordsCellArr{k} = currLcmaPixelCoords;
        end
    end
end