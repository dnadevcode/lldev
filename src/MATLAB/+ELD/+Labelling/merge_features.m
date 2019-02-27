function [optimalEstimatorDistance,fD,fdV,fO,numFeatures ] = merge_features(featuresCellArray_ordered,fD,fdV,fO,numFeatures,sets )


    import ELD.Labelling.merge_into_features;
    import ELD.Core.order_features_by_dists;

    while true

        optimalEstimatorMembers = cell(numFeatures);
        optimalEstimatorDistance = nan(numFeatures);
        optimalEstimatorVariance = nan(numFeatures);
        displayCells = cell(numFeatures);
        for featureI = 1:numFeatures-1
            for featureJ = featureI+1:min(numFeatures,featureI+10)
                [optimalEstimatorVariance(featureI,featureJ), optimalEstimatorMembers{featureI,featureJ}, ~] = graphshortestpath(sparse(fdV),featureI,featureJ);

                for featureK = 1:length(optimalEstimatorMembers{featureI,featureJ})-1
                    optimalEstimatorDistance(featureI,featureJ) = nansum([optimalEstimatorDistance(featureI,featureJ) ...
                        fD(optimalEstimatorMembers{featureI,featureJ}(featureK) , optimalEstimatorMembers{featureI,featureJ}(featureK+1)) ]);
                end

                displayCells{featureI,featureJ} = ['Feature ' num2str(featureI) '-' num2str(featureJ) ': '...
                    num2str(optimalEstimatorDistance(featureI,featureJ)) ' +- ' num2str(sqrt(optimalEstimatorVariance(featureI,featureJ)))];
            end
        end

        optimalEstimatorStds = sqrt(optimalEstimatorVariance);

        mergableFeaturesEstimators = nan(numFeatures);
        mergableFeaturesEstimators(abs(optimalEstimatorDistance) < optimalEstimatorStds * sets.confidenceInterval) = ...
            abs(optimalEstimatorDistance(abs(optimalEstimatorDistance) < optimalEstimatorStds * sets.confidenceInterval));

        if ~any(mergableFeaturesEstimators(:))
            break;
        end

        while true

            [minVal,featureMergeInd] = min(mergableFeaturesEstimators(:));
            if isnan(minVal)
                break;
            end
            [mergeFeatureA,mergeFeatureB] = ind2sub([numFeatures numFeatures],featureMergeInd);

            newFeature = merge_into_features(featuresCellArray_ordered,optimalEstimatorMembers{mergeFeatureA,mergeFeatureB},sets.minVertOverlap);

            if newFeature == 0
                mergableFeaturesEstimators(mergeFeatureA,mergeFeatureB) = NaN;
                continue;
            end

            featuresCellArray_ordered{mergeFeatureA} = newFeature;
            featuresCellArray_ordered(mergeFeatureB) = [];

            fD(:,mergeFeatureB) = [];
            fD(mergeFeatureB,:) = [];
            fdV(:,mergeFeatureB) = [];
            fdV(mergeFeatureB,:) = [];
            fO(:,mergeFeatureB) = [];
            fO(mergeFeatureB,:) = [];

            [tempDistances, tempVariances, tempOverlaps] = ELD.Labelling.calculate_feature_distances(featuresCellArray_ordered,mergeFeatureA,[],sets.minVertOverlap);

            newDataMask = ~isnan(tempDistances);
            fD(newDataMask) = tempDistances(newDataMask);
            fdV(newDataMask) = tempVariances(newDataMask);
            fO(newDataMask) = tempOverlaps(newDataMask);

            for featureI = 1:numFeatures-1

                if featureI ~= mergeFeatureA

                    minAI = min(featureI,mergeFeatureA);
                    maxAI = max(featureI,mergeFeatureA);

                    minBI = min(featureI,mergeFeatureB);
                    maxBI = max(featureI,mergeFeatureB);

                    numNewEstimatorMembersA = length(optimalEstimatorMembers{minAI,maxAI})-2; 
                    numNewEstimatorMembersB = length(optimalEstimatorMembers{minBI,maxBI})-2;

                    if numNewEstimatorMembersB > 0
                       if numNewEstimatorMembersA > 0
                            optimalEstimatorMembers{minAI,maxAI}(end+numNewEstimatorMembersB) = optimalEstimatorMembers{minAI,maxAI}(end);
                            optimalEstimatorMembers{minAI,maxAI}(end-numNewEstimatorMembersB:end-1) = optimalEstimatorMembers{minBI,maxBI}(2:end-1);

                       else
                            if numNewEstimatorMembersA == 0

                               optimalEstimatorMembers{minAI,maxAI}(end+numNewEstimatorMembersB) = optimalEstimatorMembers{minAI,maxAI}(end);
                               optimalEstimatorMembers{minAI,maxAI}(end-numNewEstimatorMembersB:end-1) = optimalEstimatorMembers{minBI,maxBI}(2:end-1);

                            else
                                if numNewEstimatorMembersA < 0
                                   optimalEstimatorMembers{minAI,maxAI}(1) = minAI;
                                   optimalEstimatorMembers{minAI,maxAI}(2:numNewEstimatorMembersB+1) = optimalEstimatorMembers{minBI,maxBI}(2:end-1);
                                   optimalEstimatorMembers{minAI,maxAI}(end+1) = maxAI;
                                end
                            end

                       end

                       removalIdx = optimalEstimatorMembers{minAI,maxAI} == optimalEstimatorMembers{minAI,maxAI}(1);
                       removalIdx = removalIdx + (optimalEstimatorMembers{minAI,maxAI} == optimalEstimatorMembers{minAI,maxAI}(end));
                       removalIdx(1) = 0;
                       removalIdx(end) = 0;
                       optimalEstimatorMembers{minAI,maxAI}(logical(removalIdx)) = [];

                       optimalEstimatorMembers{minAI,maxAI} = unique(optimalEstimatorMembers{minAI,maxAI},'stable');

                    end

                end

            end
    import ELD.Labelling.merge_into_features;
    import ELD.Core.order_features_by_dists;

    while true

        optimalEstimatorMembers = cell(numFeatures);
        optimalEstimatorDistance = nan(numFeatures);
        optimalEstimatorVariance = nan(numFeatures);
        displayCells = cell(numFeatures);
        for featureI = 1:numFeatures-1
            for featureJ = featureI+1:min(numFeatures,featureI+10)
                [optimalEstimatorVariance(featureI,featureJ), optimalEstimatorMembers{featureI,featureJ}, ~] = graphshortestpath(sparse(fdV),featureI,featureJ);

                for featureK = 1:length(optimalEstimatorMembers{featureI,featureJ})-1
                    optimalEstimatorDistance(featureI,featureJ) = nansum([optimalEstimatorDistance(featureI,featureJ) ...
                        fD(optimalEstimatorMembers{featureI,featureJ}(featureK) , optimalEstimatorMembers{featureI,featureJ}(featureK+1)) ]);
                end

                displayCells{featureI,featureJ} = ['Feature ' num2str(featureI) '-' num2str(featureJ) ': '...
                    num2str(optimalEstimatorDistance(featureI,featureJ)) ' +- ' num2str(sqrt(optimalEstimatorVariance(featureI,featureJ)))];
            end
        end

        optimalEstimatorStds = sqrt(optimalEstimatorVariance);

        mergableFeaturesEstimators = nan(numFeatures);
        mergableFeaturesEstimators(abs(optimalEstimatorDistance) < optimalEstimatorStds * sets.confidenceInterval) = ...
            abs(optimalEstimatorDistance(abs(optimalEstimatorDistance) < optimalEstimatorStds * sets.confidenceInterval));

        if ~any(mergableFeaturesEstimators(:))
            break;
        end

        while true

            [minVal,featureMergeInd] = min(mergableFeaturesEstimators(:));
            if isnan(minVal)
                break;
            end
            [mergeFeatureA,mergeFeatureB] = ind2sub([numFeatures numFeatures],featureMergeInd);

            newFeature = merge_into_features(featuresCellArray_ordered,optimalEstimatorMembers{mergeFeatureA,mergeFeatureB},sets.minVertOverlap);

            if newFeature == 0
                mergableFeaturesEstimators(mergeFeatureA,mergeFeatureB) = NaN;
                continue;
            end

            featuresCellArray_ordered{mergeFeatureA} = newFeature;
            featuresCellArray_ordered(mergeFeatureB) = [];

            fD(:,mergeFeatureB) = [];
            fD(mergeFeatureB,:) = [];
            fdV(:,mergeFeatureB) = [];
            fdV(mergeFeatureB,:) = [];
            fO(:,mergeFeatureB) = [];
            fO(mergeFeatureB,:) = [];

            [tempDistances, tempVariances, tempOverlaps] = ELD.Labelling.calculate_feature_distances(featuresCellArray_ordered,mergeFeatureA,[],sets.minVertOverlap);

            newDataMask = ~isnan(tempDistances);
            fD(newDataMask) = tempDistances(newDataMask);
            fdV(newDataMask) = tempVariances(newDataMask);
            fO(newDataMask) = tempOverlaps(newDataMask);

            for featureI = 1:numFeatures-1

                if featureI ~= mergeFeatureA

                    minAI = min(featureI,mergeFeatureA);
                    maxAI = max(featureI,mergeFeatureA);

                    minBI = min(featureI,mergeFeatureB);
                    maxBI = max(featureI,mergeFeatureB);

                    numNewEstimatorMembersA = length(optimalEstimatorMembers{minAI,maxAI})-2; 
                    numNewEstimatorMembersB = length(optimalEstimatorMembers{minBI,maxBI})-2;

                    if numNewEstimatorMembersB > 0
                       if numNewEstimatorMembersA > 0
                            optimalEstimatorMembers{minAI,maxAI}(end+numNewEstimatorMembersB) = optimalEstimatorMembers{minAI,maxAI}(end);
                            optimalEstimatorMembers{minAI,maxAI}(end-numNewEstimatorMembersB:end-1) = optimalEstimatorMembers{minBI,maxBI}(2:end-1);

                       else
                            if numNewEstimatorMembersA == 0

                               optimalEstimatorMembers{minAI,maxAI}(end+numNewEstimatorMembersB) = optimalEstimatorMembers{minAI,maxAI}(end);
                               optimalEstimatorMembers{minAI,maxAI}(end-numNewEstimatorMembersB:end-1) = optimalEstimatorMembers{minBI,maxBI}(2:end-1);

                            else
                                if numNewEstimatorMembersA < 0
                                   optimalEstimatorMembers{minAI,maxAI}(1) = minAI;
                                   optimalEstimatorMembers{minAI,maxAI}(2:numNewEstimatorMembersB+1) = optimalEstimatorMembers{minBI,maxBI}(2:end-1);
                                   optimalEstimatorMembers{minAI,maxAI}(end+1) = maxAI;
                                end
                            end

                       end

                       removalIdx = optimalEstimatorMembers{minAI,maxAI} == optimalEstimatorMembers{minAI,maxAI}(1);
                       removalIdx = removalIdx + (optimalEstimatorMembers{minAI,maxAI} == optimalEstimatorMembers{minAI,maxAI}(end));
                       removalIdx(1) = 0;
                       removalIdx(end) = 0;
                       optimalEstimatorMembers{minAI,maxAI}(logical(removalIdx)) = [];

                       optimalEstimatorMembers{minAI,maxAI} = unique(optimalEstimatorMembers{minAI,maxAI},'stable');

                    end

                end

            end

            for featureI = 1:numFeatures-1

                for featureJ = featureI+1:numFeatures

                    membersMergeFeatureB = optimalEstimatorMembers{featureI,featureJ} == mergeFeatureB;

                    membersBeyondFeatureB = optimalEstimatorMembers{featureI,featureJ} > mergeFeatureB;

                    optimalEstimatorMembers{featureI,featureJ}(membersMergeFeatureB) = mergeFeatureA;

                    optimalEstimatorMembers{featureI,featureJ}(membersBeyondFeatureB) = ...
                        optimalEstimatorMembers{featureI,featureJ}(membersBeyondFeatureB)-1;

                end
            end

            optimalEstimatorMembers(mergeFeatureB,:) = [];
            optimalEstimatorMembers(:,mergeFeatureB) = [];

            mergableFeaturesEstimators(mergeFeatureA,:) = min(mergableFeaturesEstimators(mergeFeatureA,:),mergableFeaturesEstimators(mergeFeatureB,:));
            mergableFeaturesEstimators(:,mergeFeatureA) = min(mergableFeaturesEstimators(:,mergeFeatureA),mergableFeaturesEstimators(:,mergeFeatureB));

            mergableFeaturesEstimators = min(mergableFeaturesEstimators,  mergableFeaturesEstimators.');

            mergableFeaturesEstimators(logical(tril(ones(numFeatures,numFeatures),-1))) = NaN;
            mergableFeaturesEstimators(mergeFeatureA,mergeFeatureA) = NaN;

            mergableFeaturesEstimators(mergeFeatureB,:) = [];
            mergableFeaturesEstimators(:,mergeFeatureB) = [];

            numFeatures = numFeatures-1;

        end

    end


            for featureI = 1:numFeatures-1

                for featureJ = featureI+1:numFeatures

                    membersMergeFeatureB = optimalEstimatorMembers{featureI,featureJ} == mergeFeatureB;

                    membersBeyondFeatureB = optimalEstimatorMembers{featureI,featureJ} > mergeFeatureB;

                    optimalEstimatorMembers{featureI,featureJ}(membersMergeFeatureB) = mergeFeatureA;

                    optimalEstimatorMembers{featureI,featureJ}(membersBeyondFeatureB) = ...
                        optimalEstimatorMembers{featureI,featureJ}(membersBeyondFeatureB)-1;

                end
            end

            optimalEstimatorMembers(mergeFeatureB,:) = [];
            optimalEstimatorMembers(:,mergeFeatureB) = [];

            mergableFeaturesEstimators(mergeFeatureA,:) = min(mergableFeaturesEstimators(mergeFeatureA,:),mergableFeaturesEstimators(mergeFeatureB,:));
            mergableFeaturesEstimators(:,mergeFeatureA) = min(mergableFeaturesEstimators(:,mergeFeatureA),mergableFeaturesEstimators(:,mergeFeatureB));

            mergableFeaturesEstimators = min(mergableFeaturesEstimators,  mergableFeaturesEstimators.');

            mergableFeaturesEstimators(logical(tril(ones(numFeatures,numFeatures),-1))) = NaN;
            mergableFeaturesEstimators(mergeFeatureA,mergeFeatureA) = NaN;

            mergableFeaturesEstimators(mergeFeatureB,:) = [];
            mergableFeaturesEstimators(:,mergeFeatureB) = [];

            numFeatures = numFeatures-1;

        end

    end

    

end

