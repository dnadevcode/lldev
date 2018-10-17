% function featureDistances=getFeatureDistsances(inputStruct_smooth,inputStruct_raw)
function [featuresCellArray_processed, featureDistances, featureDistanceVariances] = get_feature_distances(kymo,settings,backgroundCompensation)

    import ELD.Core.get_color_map;

    if nargin < 1 || isempty(kymo)
        
        import ELD.Import.import_tiff_img
        kymo = import_tiff_img();
        
    end
    
    if nargin < 2 || isempty(settings)
        import ELD.Import.load_eld_kymo_align_settings;
        settings = load_eld_kymo_align_settings();
    end
    
    if nargin < 3 || isempty(backgroundCompensation)
        backgroundCompensation = false;
    end
    
    minOverlap = settings.minVerticalOverlap;
    confidenceInterval = settings.confidenceInterval;

%     fullTimer = tic;

    import ELD.Core.generate_peak_bitMap;
    import ELD.Core.remove_weak_peaks;
    import ELD.Core.generate_peak_graph;
    import ELD.Core.process_peak_graph;
    import ELD.Core.organize_features;
    if backgroundCompensation
        peakBitMap=generate_peak_bitMap(kymo);
        peakBitMap=peakBitMap.*(~(kymo<=0));
        
        peakBitMap = remove_weak_peaks(kymo,peakBitMap);

        %Remove all isolated pixels in the peakBitMap i.e pixles which dont have pixel above or below within the range specified by 'k'.
        sel=zeros(3,2*settings.localFluctuationWindow+1);
        sel(1,:)=1;
        sel(3,:)=1;
        tmp_1=imdilate(peakBitMap,sel); 
        peakBitMap=peakBitMap.*tmp_1;

        %Graph Based Computatations.
        S=generate_peak_graph(kymo,settings.localFluctuationWindow,peakBitMap);%Create a graph

        %Process the connected components and save only those whose size is greater than the threshold.
        featuresCellArray=process_peak_graph(S,settings.minimumSizeOfConnectedComponent);

        if size(featuresCellArray,2) < 2
            fprintf('Less than two features were detected.\n');
            featuresCellArray_processed = [];
            featureDistances = [];
            featureDistanceVariances = [];
            return;
        end

        %Organize components by mean horizontal position, and generate a
        %feature map for further computations, and a color map for displaying purposes.
        [featureMap,~,~] = organize_features(featuresCellArray,size(kymo));        

        signalMap = featureMap >= 1;
        signalMap = imdilate(signalMap,ones(1,11));

        import ELD.Core.subtract_kymo_background;
        kymo = subtract_kymo_background( kymo, signalMap );  
    end

    peakBitMap = generate_peak_bitMap(kymo);
    peakBitMap = peakBitMap.*(~(kymo<=0));

    peakBitMap = remove_weak_peaks(kymo,peakBitMap);

    %Remove all isolated pixels in the peakBitMap i.e pixles which dont have pixel above or below within the range specified by 'k'.
    sel=zeros(3,2*settings.localFluctuationWindow+1);
    sel(1,:)=1;
    sel(3,:)=1;
    tmp_1=imdilate(peakBitMap,sel); 
    peakBitMap=peakBitMap.*tmp_1;

    %Graph Based Computatations.
    S=generate_peak_graph(kymo,settings.localFluctuationWindow,peakBitMap);%Create a graph

    featuresCellArray=process_peak_graph(S,settings.minimumSizeOfConnectedComponent);%Process the connected components and save only those whose size is greater than the threshold.

    if size(featuresCellArray,2) < 2
        fprintf('Less than two features were detected.\n');
        featuresCellArray_processed = [];
        featureDistances = [];
        featureDistanceVariances = [];
        return;
    end

    [~,~,featuresCellArray_ordered] = organize_features(featuresCellArray,size(kymo));

    %Create peak table.
    peakTable = nan(size(kymo,1),numel(featuresCellArray_ordered));
    for i = 1:numel(featuresCellArray_ordered)
        peakTable(featuresCellArray_ordered{i}(:,1),i) = featuresCellArray_ordered{i}(:,2);
    end
    
    
    numFeatures = numel(featuresCellArray_ordered);

    distancesToCheck = 1:numFeatures;

    import ELD.Core.calculate_feature_distances
    [featureDistance, featureDistanceVariance, featureOverlaps] = calculate_feature_distances(featuresCellArray_ordered,distancesToCheck,[],minOverlap);

    import ELD.Core.merge_features;
    import ELD.Core.order_features_by_dists;

    while true

        optimalEstimatorMembers = cell(numFeatures);
        optimalEstimatorDistance = nan(numFeatures);
        optimalEstimatorVariance = nan(numFeatures);
        displayCells = cell(numFeatures);
        for featureI = 1:numFeatures-1
            for featureJ = featureI+1:min(numFeatures,featureI+10)
                [optimalEstimatorVariance(featureI,featureJ), optimalEstimatorMembers{featureI,featureJ}, ~] = graphshortestpath(sparse(featureDistanceVariance),featureI,featureJ);

                for featureK = 1:length(optimalEstimatorMembers{featureI,featureJ})-1
                    optimalEstimatorDistance(featureI,featureJ) = nansum([optimalEstimatorDistance(featureI,featureJ) ...
                        featureDistance(optimalEstimatorMembers{featureI,featureJ}(featureK) , optimalEstimatorMembers{featureI,featureJ}(featureK+1)) ]);
                end

                displayCells{featureI,featureJ} = ['Feature ' num2str(featureI) '-' num2str(featureJ) ': '...
                    num2str(optimalEstimatorDistance(featureI,featureJ)) ' +- ' num2str(sqrt(optimalEstimatorVariance(featureI,featureJ)))];
            end
        end

        optimalEstimatorStds = sqrt(optimalEstimatorVariance);

        mergableFeaturesEstimators = nan(numFeatures);
        mergableFeaturesEstimators(abs(optimalEstimatorDistance) < optimalEstimatorStds * confidenceInterval) = ...
            abs(optimalEstimatorDistance(abs(optimalEstimatorDistance) < optimalEstimatorStds * confidenceInterval));

        if ~any(mergableFeaturesEstimators(:))
            break;
        end

        while true

            [minVal,featureMergeInd] = min(mergableFeaturesEstimators(:));
            if isnan(minVal)
                break;
            end
            [mergeFeatureA,mergeFeatureB] = ind2sub([numFeatures numFeatures],featureMergeInd);

            newFeature = merge_features(featuresCellArray_ordered,optimalEstimatorMembers{mergeFeatureA,mergeFeatureB},minOverlap);

            if newFeature == 0
                mergableFeaturesEstimators(mergeFeatureA,mergeFeatureB) = NaN;
                continue;
            end

            featuresCellArray_ordered{mergeFeatureA} = newFeature;
            featuresCellArray_ordered(mergeFeatureB) = [];

            featureDistance(:,mergeFeatureB) = [];
            featureDistance(mergeFeatureB,:) = [];
            featureDistanceVariance(:,mergeFeatureB) = [];
            featureDistanceVariance(mergeFeatureB,:) = [];
            featureOverlaps(:,mergeFeatureB) = [];
            featureOverlaps(mergeFeatureB,:) = [];

            [tempDistances, tempVariances, tempOverlaps] = calculate_feature_distances(featuresCellArray_ordered,mergeFeatureA,[],minOverlap);

            newDataMask = ~isnan(tempDistances);
            featureDistance(newDataMask) = tempDistances(newDataMask);
            featureDistanceVariance(newDataMask) = tempVariances(newDataMask);
            featureOverlaps(newDataMask) = tempOverlaps(newDataMask);

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

    featureDistances = diag(optimalEstimatorDistance,1);
    [featureDistances, sorting] = order_features_by_dists(featureDistances);

    featureDistanceVariance = featureDistanceVariance(sorting,sorting);


    for featureI = 1:numFeatures-1
        [featureDistanceVariances(featureI), ~, ~] = graphshortestpath(sparse(featureDistanceVariance),featureI,featureI+1);
    end

    featuresCellArray_processed = featuresCellArray_ordered(sorting);
    
%     fullTime = toc(fullTimer)

end
