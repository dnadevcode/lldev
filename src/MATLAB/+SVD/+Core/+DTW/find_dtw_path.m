function [pathCoords] = find_dtw_path(accumCostMat)
    %Computes the DTW path. Modifies classic DTW to allow passage
    %through left and right walls.
    %Inputs:
    %   accumCostMat - Accumulated Cost Matrix.
    %Outputs:
    %   pathCoords - DTW path (array of [x-index y-index] for each step) 
    n = size(accumCostMat, 1);
    [~, m] = min(accumCostMat(n,:));
    pathCoordIdx = 0;
    pathCoords = cell(n + m, 1);
    pathCoordIdx = pathCoordIdx + 1;
    pathCoords{pathCoordIdx} = [n m];
    jumpCheck = false;
    while n > 1
        if m == 2
            jumpCheck = true;
            [~,i] = min([accumCostMat(n-1,end), accumCostMat(n-1,m), accumCostMat(n,end)]);
        else
            [~,i] = min([accumCostMat(n-1,m-1), accumCostMat(n-1,m), accumCostMat(n,m-1)]);
        end
        if i == 2
            n = n-1;
        elseif i == 1 && ~jumpCheck
            n = n-1;
            m = m-1;
        elseif i == 1 && jumpCheck
            n = n-1;
            m = length(accumCostMat(1,:));
        elseif ~jumpCheck
            m = m-1;
        else
            m = length(accumCostMat(1,:));
        end
        if m == length(accumCostMat(1,:));
            pathCoordIdx = pathCoordIdx + 1;
            pathCoords{pathCoordIdx} = [NaN NaN];
        end
        jumpCheck = false;
        pathCoordIdx = pathCoordIdx + 1;
        pathCoords{pathCoordIdx} = [n m];
    end
    pathCoords = vertcat(pathCoords{1:pathCoordIdx});

    %The following two lines compensates for the extra row and
    %column in the ACM (only for plotting purposes):
    pathCoords(end,:) = [];
    pathCoords = pathCoords - 1;
end