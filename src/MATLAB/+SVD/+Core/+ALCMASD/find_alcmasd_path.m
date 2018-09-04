function [pathCoords, cumCostVect] = find_alcmasd_path(costMatrix, accumulatedCostMatrix, numBestPaths, lcmaPixelCount, bandWidth)
    %Computes the global alignment path with the usage of LCMA
    %segments. 'bestPathCount' is the number of bands to include
    %as potential step-holders for the global alignment path.
    %'cumCostVect' is a two column array with x-index in column one
    %and y-index in column two. 'totalCost' stores the step
    %cost for each step in the global path.
    numRows = size(costMatrix, 1);
    numCols = size(costMatrix, 2);

    import SVD.Core.ALCMASD.find_alcmasd_paths;
    [paths, pathCosts] = find_alcmasd_paths(costMatrix, accumulatedCostMatrix, bandWidth);
    %Applies ceiling to bestPathCount
    numBestPaths = min(numBestPaths, ceil(numCols/(4 * bandWidth + 2)));

    bandIndex = zeros(1,numBestPaths);
    for bestPathIdx = 1:numBestPaths
        [~, bandIndex(bestPathIdx)] = max(lcmaPixelCount);
        lcmaPixelCount(bandIndex(bestPathIdx)) = 0;
    end

    cumCostVect(1:numRows) = Inf;
    pathCoords = zeros(numRows, 2);            
    for bestPathIdx = 1:numBestPaths
        tmpPathCosts = pathCosts{bandIndex(bestPathIdx)};
        for tmpPathCostsIdx = 1:length(tmpPathCosts)
            x_coord = paths{bandIndex(bestPathIdx)}(tmpPathCostsIdx,1);
            if tmpPathCosts(tmpPathCostsIdx) < cumCostVect(x_coord)
                cumCostVect(x_coord) = tmpPathCosts(tmpPathCostsIdx);
                pathCoords(x_coord,:) = [x_coord paths{bandIndex(bestPathIdx)}(tmpPathCostsIdx,2)];
            end
        end
    end
end