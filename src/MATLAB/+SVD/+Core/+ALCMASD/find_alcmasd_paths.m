function [path, pathCost, numberOfBands] = find_alcmasd_paths(costMat, accumCostMat, bandWidth)
    %Computes and stores the paths and path costs for every band.
    %Input: cost matrix, accumulated cost matrix and a band
    %range parameter that sets the width of the bands to
    %2*bandWidth+1.
    %Output: DTW path (cell array of [x-index y-index] for each
    %step) with the optimal DTW path for each band in a separate
    %cell. Total Cost (cell array of costs for each step in the DTW paths)
    %with the cost for each bands path in a separate cell.
    numRows = size(costMat, 1);
    numCols = size(costMat, 2);
    xLength = numRows;
    numberOfBands = ceil(numCols/(4*bandWidth+2));
    bandCenterColumnIndex = zeros(numberOfBands,1);
    pathStartColumnIndex = zeros(numberOfBands,1);
    path = cell(numberOfBands,1);
    pathCost = cell(numberOfBands,1);
    p = 0;

    %Setting up path centres and starting coordinates for each
    %path:
    for bandIdx = 1:numberOfBands
        bandCenterColumnIndex(bandIdx) = bandWidth*(2*bandIdx - 1) + bandIdx;
        try
            [~, pathStartColumnIndex(bandIdx)] = min(accumCostMat(end,((bandCenterColumnIndex(bandIdx)+xLength-bandWidth):(bandCenterColumnIndex(bandIdx)+xLength+bandWidth))));
        catch %Catches the case when the band width is large enought to exceed the bounds of the ACM.
            [~, pathStartColumnIndex(bandIdx)] = min(accumCostMat(end,((bandCenterColumnIndex(bandIdx)+xLength-bandWidth):end)));
        end
        path{bandIdx} = [(xLength+1) (xLength+pathStartColumnIndex(bandIdx)+bandCenterColumnIndex(bandIdx)-bandWidth-1)];
        pathCost{bandIdx} = 0;

        %Computing the paths:
        n = path{bandIdx}(1,1);
        m = path{bandIdx}(1,2);              
        while n > 1 && m > 1    %Continues ultil path reaches row or column one.
            %Checks for the next step
            if abs((n-(xLength+1))-(m-(xLength+bandCenterColumnIndex(bandIdx)))) < bandWidth-p %Checks for Sakoe width constraint.
                %Max deviation is +/-bandWidth i.e. total width = 2bandWidth+1.
                %Observe that p above restricts the paths to be separated
                %by p pixels. This could be good to prevent adjacent bands to
                %find paths that are very similar in cost but it is
                %not used here.
                [~,i] = min([accumCostMat(n-1,m-1), accumCostMat(n-1,m), accumCostMat(n,m-1)]); %Ordinary path.
            elseif (n-xLength+1)-(m-(xLength+bandCenterColumnIndex(bandIdx))) < 0 %x-coord at cap, n-step not allowed.
                [~,i] = min([accumCostMat(n-1,m-1), Inf, accumCostMat(n,m-1)]);
            elseif (n-xLength+1)-(m-(xLength+bandCenterColumnIndex(bandIdx))) > 0 %y-coord at cap, m-step not allowed.
                [~,i] = min([accumCostMat(n-1,m-1), accumCostMat(n-1,m), Inf]);
            end
            if i == 1
                n = n-1;
                m = m-1;
            elseif i == 2
                n = n-1;
            else
                m = m-1;
            end
            path{bandIdx} = cat(1, path{bandIdx}, [n m]);
            if n > 1 && m > 1
                pathCost{bandIdx} = cat(1, pathCost{bandIdx}, costMat(n-1,m-1));
                %Observe that costMatrix has one less row and
                %column, hence the minus 1's above.
            end
        end
        %Flips the paths to have the top row in index 1:
        path{bandIdx} = flipud(path{bandIdx});
        pathCost{bandIdx} = flipud(pathCost{bandIdx});
    end
end