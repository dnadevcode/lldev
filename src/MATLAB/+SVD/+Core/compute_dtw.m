function [dtwUnnormalizedDist, accumulatedDistMat, normalizationFactor, optimalPathCoords] = compute_dtw(vectA, vectB, weightHorizMove, weightVertMove, weightDiagMove)
    % COMPUTE_DTW
    % Dynamic Time Warping Algorithm
    %
    % Inputs:
    %   vectA
    %   vectB
    %   weightHorizMove
    %   weightVertMove
    %   weightDiagMove
    %
    % Outputs: 
    %   dtwUnnormalizedDist
    %   accumulatedDistMat
    %   normalizationFactor
    %   optimalPathCoords
    %
    % Authors:
    %   Erik Lagerstedt
    %   Saair Quaderi (refactoring)


    if nargin < 3
        weightHorizMove = 1;
    end
    if nargin < 4
        weightVertMove = 1;
    end
    if nargin < 5
        weightDiagMove = 1;
    end

    squaredDiffsMat = bsxfun(@minus, vectA(:), vectB(:)').^2;

    accumulatedDistMat = inf(size(squaredDiffsMat));
    accumulatedDistMat(1, 1) = squaredDiffsMat(1,1);

    lenA = length(vectA);
    for idxA = 2:lenA
        accumulatedDistMat(idxA, 1) = weightVertMove*squaredDiffsMat(idxA,1) + accumulatedDistMat(idxA - 1,1);
    end
    lenB = length(vectB);
    for idxB = 2:lenB
        accumulatedDistMat(1, idxB) = squaredDiffsMat(1, idxB);
    end

    for idxA = 2:lenA
        for idxB = 2:lenB
            vertMoveCost = accumulatedDistMat(idxA - 1 , idxB) + (weightVertMove * squaredDiffsMat(idxA, idxB));
            horizMoveCost = accumulatedDistMat(idxA, idxB - 1) + (weightHorizMove * squaredDiffsMat(idxA, idxB));
            diagMoveCost =  accumulatedDistMat(idxA - 1, idxB - 1) + (weightDiagMove * squaredDiffsMat(idxA, idxB));
            minMoveCost = min([vertMoveCost, horizMoveCost, diagMoveCost]);
            accumulatedDistMat(idxA, idxB) = minMoveCost; 
        end
    end


    idxA = lenA;
    [dtwUnnormalizedDist, idxB] = min(accumulatedDistMat(lenA,:));

    normalizationFactor = 1;
    
    optimalPathCoordIdx = 0;
    optimalPathCoords = cell(lenA + lenB, 1);
    
    optimalPathCoordIdx = optimalPathCoordIdx + 1;
    optimalPathCoords{optimalPathCoordIdx} = [idxA, idxB];

    while (idxA > 1) && (idxB > 1)
        if ((idxA - 1) == 0)
            idxB = idxB-1;
        elseif ((idxB - 1) == 0)
            idxA = idxA - 1;
        else
            [~, minMoveTypeIdx] = min(...
                [...
                    accumulatedDistMat(idxA - 1, idxB), ... % vertical
                    accumulatedDistMat(idxA, idxB - 1), ... % horizontal
                    accumulatedDistMat(idxA - 1, idxB - 1) ... % diagonal
                ]);
            switch minMoveTypeIdx
                case 1 % vertical
                    idxA = idxA - 1;
                case 2 % horizontal
                    idxB = idxB - 1;
                case 3 % diagonal
                    idxA = idxA - 1;
                    idxB = idxB - 1;
            end
        end
        normalizationFactor = normalizationFactor + 1;

        optimalPathCoordIdx = optimalPathCoordIdx + 1;
        optimalPathCoords{optimalPathCoordIdx} = [idxA, idxB];
    end
    optimalPathCoords = vertcat(optimalPathCoords{1:optimalPathCoordIdx});
end
