function [ featureDistance, featureDistanceVariances , featureOverlap] = calculate_neighbor_distance( featureI, featureJ, minOverlap)
    
% Calculate the mean distance between two features.
% Input: 
%         featureI and featureJ:
%         The two feature for which the distance is to be calculated. Each 
%         feature is an array containing the indices for the position 
%         of the feature. Each row corresponds to the position
%         of one pixel belonging to the feature.
%         minOverlap: The minimum vertical overlap (in pixels) between
%         features, for them to be considered truly overlapping. 
% Output:
%         featureDistance: The calculated distance between the features.
%         featureDistanceVariances: The calculated variance in the distance 
%         between the features.
%         featureOverlap: The vertical overlap (in pixels) between the 
%         features.

    if nargin < 2 || isempty(featureI) || isempty(featureJ)
        disp('Two features have to be defined.');
        return;
    end
    
    if nargin < 3 || isempty(minOverlap)
        minOverlap = 5;
    end
    
    featureOverlap = 0;
    featureDistance = 0;
    featureSquareDistance = 0;
            
    [~,rowsInJ] = ismember(featureI(:,1),featureJ(:,1));
    [~,rowsInI] = ismember(featureJ(:,1),featureI(:,1));

    rowsInI = nonzeros(rowsInI);
    rowsInJ = nonzeros(rowsInJ);

    if numel(rowsInI) < minOverlap || isempty(rowsInI)
        disp('Features do not overlap');
        featureDistance = nan;
        featureDistanceVariances = nan;
    else

        for rowInd = 1:length(rowsInI)
            rowInI = rowsInI(rowInd);
            rowInJ = rowsInJ(rowInd);

            featureDistance = featureDistance + ...
                featureJ(rowInJ,2) - featureI(rowInI,2);
            featureSquareDistance = featureSquareDistance + ...
                (featureJ(rowInJ,2) - featureI(rowInI,2)).^2;
            featureOverlap = featureOverlap + 1;

        end

        featureDistance = featureDistance ./ featureOverlap;
        featureSquareDistance = featureSquareDistance ./ featureOverlap;
        featureDistanceVariances = featureSquareDistance - featureDistance.^2;
        
    end
    
end