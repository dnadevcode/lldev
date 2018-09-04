function [pathCostMat, pathMat] = compute_mvm_path_cost(costMatrix, winWidth)
    %Computes pathcost and path  matrix for two sequences according
    % to the paper by Latecki et al (2007). winWidth is an optional
    % parameter that sets a ceiling for the maximum jump length.

    
    costMatNumRows = size(costMatrix, 1);
    costMatNumCols = size(costMatrix, 2);
    elasticity = min(costMatNumCols - costMatNumRows, winWidth);
    pathCostMat = zeros(costMatNumRows, costMatNumCols);
    pathMat = zeros(costMatNumRows, costMatNumCols);
    for i = 1:costMatNumRows
        for j = 1:costMatNumCols
            pathCostMat(i,j) = Inf;
            pathMat(i,j) = 0;
        end
    end
    for j = 1:elasticity + 1
        pathCostMat(1,j) = costMatrix(1,j)^2;
    end
    for i = 2:costMatNumRows
        stopk = min(i-1 + elasticity, costMatNumCols);
        for k = i-1:stopk
            stopj = min(k+1+elasticity, costMatNumCols);
            for j = (k+1):stopj
                if pathCostMat(i,j)>pathCostMat(i-1,k)+costMatrix(i,j)^2
                    pathCostMat(i,j) = pathCostMat(i-1,k)+costMatrix(i,j)^2;
                    pathMat(i,j) = k;
                end
            end
        end
    end
end