function [alignXVals, bestDist] = find_single_feature(regArr, maxFeatureMovementPx, barrierVal)
    % FIND_SINGLE_FEATURE - detects a single "feature" in the WPAlign algorithm
    %	(see the WPAlign paper for details)
    %
    % Inputs:
    %	regArr
    %	  the array to detect the feature in
    %	maxFeatureMovementPx
    %	  the number of pixels to the left- or to the right- that the feature can jump in
    %	each step)
    %	barrierVal
    %	  the parameter B in the algorithm
    %
    % Outputs: 
    %	alignXVals
    %	  the position of the best feature
    %	bestDist
    %	  the path length of the feature
    % 
    % Authors:
    %	Charleston Noble
    %

    rows = size(regArr,1);
    cols = size(regArr,2);

    import OptMap.KymoAlignment.apply_laplacian_of_gaussian_filter;
    k = apply_laplacian_of_gaussian_filter(regArr, [2, 6], 2);

    k(k>0) = k(k>0) ./ max(k(:));
    k(k<0) = k(k<0) ./ max(-k(:));

    kUp = k;
    kUp(kUp>0) = 1 - kUp(kUp>0);
    kUp(kUp<=0) = barrierVal; 

    kDown = -k;
    kDown(kDown>0) = 1 - kDown(kDown>0);
    kDown(kDown<=0) = barrierVal;

    distArr = [inf, inf];
    alignXValsArr = zeros(rows,2);


    for arbitraryRepeat = 1:2

        if arbitraryRepeat == 1
            weightImg = kUp;
        else
            weightImg = kDown;
        end

        idxs = zeros(1,maxFeatureMovementPx);
        idxs(1) = 1;

        P = maxFeatureMovementPx-1;
        M = rows*(cols+P) + 2;    

        paddedImg = zeros(size(weightImg,1), size(weightImg,2)+P);
        paddedImg(:,P/2+1:end-P/2) = weightImg;
        paddedImg(:,[1:P/2, end-P/2+1:end]) = -1;
        paddedImg = paddedImg';
        paddedImg = paddedImg(:);

        % Creating row_G with padding connections
        first_row_G = ones(1,cols);    
        second_row_G = 2:M-1-cols-P;    
        x = [2:P/2+1, (2+cols+P/2):(cols+P+1)];
        xRep = repmat(x, rows-1, 1);
        jumpMat = cumsum((cols + P) * ones(rows-1, P)) - (cols+P);
        removeIdxs = xRep + jumpMat - 1;    
        second_row_G(removeIdxs(:)) = [];    
        second_row_G = second_row_G(cumsum(repmat(idxs,1,length(second_row_G))));    
        third_row_G = M-cols-P/2:M-1-P/2;    
        I = [first_row_G, second_row_G, third_row_G];

        % Creating J vector with padding connections
        first_J = P/2+2:cols+P/2+1;
        x = (2+P + cols) : (cols+P) : (2+(rows-1)*(cols+P));
        xRep = repmat(x, cols, 1);
        jumpMat = cumsum(ones(cols, length(x))) - 1;
        idx = xRep+jumpMat;
        idx = idx(:)';
        idxRep = repmat(idx, maxFeatureMovementPx, 1);
        jumpMat = cumsum(ones(maxFeatureMovementPx, length(idxRep))) - 1;
        second_J = idxRep + jumpMat;
        second_J = second_J(:)';
        J = [first_J, second_J];
        S = paddedImg(J-1);
        third_J = M * ones(1,cols);
        J = [J third_J];
        S = [S; ones(cols, 1)]';

        removeIdxs = find(S == -1);

        I(removeIdxs) = [];
        J(removeIdxs) = [];
        S(removeIdxs) = [];

        [distP, path, ~] = graphshortestpath(sparse(I, J, S, M, M), 1, M, 'method', 'acyclic');

        distArr(arbitraryRepeat) = distP;
        alignXValsArr(:,arbitraryRepeat) = (mod(path(2:rows+1)-1, cols+P) - P/2)';

    end

    [distSort, bestIdx] = sort(distArr);
    bestDist = distSort(1);
    alignXVals = alignXValsArr(:, bestIdx(1));
end