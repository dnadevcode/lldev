function [ featureDistances, featureDistanceVariances , featureOverlaps] = calculate_feature_distances( featuresCellArray , featuresI, featuresJ, minOverlap)

    numFeatures = numel(featuresCellArray);
    
    if nargin < 2 || isempty(featuresI)
        featuresI = 1:numFeatures;
    end
        
    if nargin < 3 || isempty(featuresJ)
        featuresJ = 1:numFeatures;
    end
    
    if nargin < 4 || isempty(minOverlap)
        minOverlap = 5;
    end
    
%     numI = length(featuresI);
%     numJ = length(featuresJ);
    
    featureDistancesCalculated = zeros(numFeatures);
    
    featureOverlaps = zeros(numFeatures);
    featureDistances = nan(numFeatures);
    featureSquareDistances = nan(numFeatures);
    
    
    for featureI = featuresI
        for featureJ = featuresJ
            
            if featureI ~= featureJ && ~featureDistancesCalculated(featureI,featureJ)
                
                featureDistancesCalculated(featureI,featureJ) = 1;
                featureDistancesCalculated(featureJ,featureI) = 1;
            
                [~,rowsInJ] = ismember(featuresCellArray{featureI}(:,1),featuresCellArray{featureJ}(:,1));
                [~,rowsInI] = ismember(featuresCellArray{featureJ}(:,1),featuresCellArray{featureI}(:,1));

                rowsInI = nonzeros(rowsInI);
                rowsInJ = nonzeros(rowsInJ);

                if ~isnan(rowsInJ)

                    featureDistances(featureI,featureJ) = 0;
                    featureSquareDistances(featureI,featureJ) = 0;

                    for rowInd = 1:length(rowsInI)
                        rowInI = rowsInI(rowInd);
                        rowInJ = rowsInJ(rowInd);

                        featureDistances(featureI,featureJ) = featureDistances(featureI,featureJ) + ...
                            featuresCellArray{featureJ}(rowInJ,2) - featuresCellArray{featureI}(rowInI,2);
                        featureSquareDistances(featureI,featureJ) = featureSquareDistances(featureI,featureJ) + ...
                            (featuresCellArray{featureJ}(rowInJ,2) - featuresCellArray{featureI}(rowInI,2)).^2;
                        featureOverlaps(featureI,featureJ) = featureOverlaps(featureI,featureJ) + 1;

                    end


                    featureOverlaps(featureJ,featureI) = featureOverlaps(featureI,featureJ);
                    featureSquareDistances(featureJ,featureI) = featureSquareDistances(featureI,featureJ);
            %         
                    featureDistances(featureJ,featureI) = -featureDistances(featureI,featureJ);

                end
            end
        end
    end

%     featureOverlaps(logical(eye(size(featureOverlaps)))) = 1;
%     featureDistances(logical(eye(size(featureOverlaps)))) = 0;
%     featureSquareDistances(logical(eye(size(featureOverlaps)))) = 0;
%     featureDistanceVariances(logical(eye(size(featureOverlaps))) = 0;

    featureDistances = featureDistances ./ featureOverlaps;
    featureSquareDistances = featureSquareDistances ./ featureOverlaps;
    featureDistanceVariances = featureSquareDistances - featureDistances.^2;


    removalMask = zeros(size(featureDistances));
    removalMask(featureOverlaps<minOverlap) = 1;
%     removalMask(logical(eye(size(removalMask)))) = 0;

    removalMask = logical(removalMask);

    featureDistances(removalMask) = NaN;
%     featureSquareDistances(removalMask) = NaN;
    featureDistanceVariances(removalMask) = Inf;

    featureDistanceVariances(isnan(featureDistanceVariances)) = Inf;
    


end

