% function [featureDistances] = get_feature_distances(inputStruct_smooth, inputStruct_raw)
function [featureDistance] = get_feature_distances(inputStruct_smooth)
    import ELD.Import.load_eld_kymo_align_settings;
    eldKymoAlignSettings = load_eld_kymo_align_settings(); % A struct containing all parameters used.


    if nargin < 1
        [kymoFilename, dirpath] = uigetfile('*.mat', 'Select mat-file with unaligned kymograph', 'Multiselect', 'off');
        aborted = isequal(dirpath, 0);
        if aborted
            return;
        end
        kymoFilepath = fullfile(dirpath, kymoFilename);

        inputStruct_smooth = load(kymoFilepath);
        inputStruct_smooth = inputStruct_smooth.processedKymo;
    % elseif not(isequal(size(inputStruct_smooth), size(inputStruct_raw)))
    %     return;
    end


    % After the background subtraction, a kymograph may have negative values which 
    % can't be accurately displayed so a corresponding kymograph without any
    % background subtraction
    % is used for all visual demonstration purposes. All such results are marked
    % with the suffix "_show"

    % raw = inputStruct_raw.kymo_dynamicMeanSubtraction;
    % raw_show = inputStruct_raw.kymo_noSubtraction;
    tic;
    imgArr = inputStruct_smooth.kymo_dynamicMeanSubtraction;
    imgArr_show = inputStruct_smooth.kymo_noSubtraction;
    

    import ELD.Core.generate_peak_bitmap;
    peakBitMap = generate_peak_bitmap(imgArr);
    peakBitMap = peakBitMap.*(~(imgArr<=0));


    % Remove all isolated pixels in the peakBitMap i.e pixles which dont have pixel above or below within the range specified by 'k'.
    sel = zeros(3,2*eldKymoAlignSettings.localFluctuationWindow+1);
    sel(1,:) = 1;
    sel(3,:) = 1;
    tmp_1 = imdilate(peakBitMap,sel); 
    peakBitMap = peakBitMap.*tmp_1;
    toc;

    tic;
    % Graph Based Computatations.
    import ELD.Core.generate_peak_graph;
    S = generate_peak_graph(imgArr, eldKymoAlignSettings.localFluctuationWindow, peakBitMap);%Create a graph
    toc;
    tic;
    import ELD.Core.process_peak_graph;
    featuresCellArray = process_peak_graph(S, eldKymoAlignSettings.minimumSizeOfConnectedComponent);%Process the connected components and save only those whose size is greater than the threshold.
%     featuresCellArray_connected = connectGroups_1(featuresCellArray,size(imgArr),settings.featureMeanFluctuationWindow); % connect features corresponding to the same labelled segment.
    toc;
    % unalignedFeatureMap = label_features(featuresCellArray_connected,size(imgArr));
    
    import ELD.Core.organize_features;
    % [~, featuresCellArray_ordered] = organize_features(featuresCellArray_connected,size(imgArr));
    tic;
    [featureMap,colorMap,featuresCellArray_ordered] = organize_features(featuresCellArray,size(imgArr));
    toc;
    
%     signalMap = featureMap > =  1;
%     signalMap = imdilate(signalMap,ones(1,11));
    
    
%     backgroundNoise = nanmean(imgArr.*~signalMap);
%     figure, plot(backgroundNoise);
    
%     coeff = polyfit(1:length(backgroundNoise),backgroundNoise,1);
%     
% %     slope = 1:length(backgroundNoise) \ backgroundNoise;
%     backgroundNoise = coeff(2) + coeff(1) .* (1:length(backgroundNoise));
%     figure, plot(backgroundNoise);
%     
%     imgArr_backGroundSubtracted = imgArr;
%     for row = 1:numRows
%         imgArr_backGroundSubtracted(row,:) = imgArr(row,:) - backgroundNoise;
%     end
    
    % markedIndividualFeatures = peekcolor(imgArr_show,featuresCellArray,0);%Mark obtained  individual features on the kymograph for visual demonstration.
    % markedConnectedFeatures = peekcolor(imgArr_show,featuresCellArray_connected,0);%Mark connected features on the kymograph for visual demonstration.

    figure;
    subplot(1,2,1);
    imagesc(imgArr_show);
    colorbar;
    subplot(1,2,2);
    imagesc(colorMap);

    
    numFeatures = numel(featuresCellArray_ordered);
    twoFeatureOverlap = zeros(numFeatures);
    featureDistance = zeros(numFeatures);
    featureSquareDistance = zeros(numFeatures);
% %     featureDistanceVariances = zeros(numFeatures);
%     featureDistanceCrossProducts = zeros(numFeatures,numFeatures,numFeatures);
%     threeFeatureOverlap = zeros(numFeatures,numFeatures,numFeatures);
    tic;
    for featureI = 1:numFeatures
        for featureJ = featureI+1:numFeatures
            [~,rowsInJ] = ismember(featuresCellArray_ordered{featureI}(:,1),featuresCellArray_ordered{featureJ}(:,1));
            [~,rowsInI] = ismember(featuresCellArray_ordered{featureJ}(:,1),featuresCellArray_ordered{featureI}(:,1));
            
            rowsInI = nonzeros(rowsInI);
            rowsInJ = nonzeros(rowsInJ);
            
            if ~isnan(rowsInJ)
                
                for rowInd = 1:length(rowsInI)
                    rowInI = rowsInI(rowInd);
                    rowInJ = rowsInJ(rowInd);

        %             rowInI = featuresCellArray_ordered{featureI}(rowInI,1);
    %                 rowInJ = find(featuresCellArray_ordered{featureJ}(:,1)  ==  featuresCellArray_ordered{featureI}(rowInI,1));
    %                 if ~isnan(rowInJ)
        %                 featureI = featureI
        %                 featureJ = featureJ
        %                 rowInI = rowInI
        %                 rowInJ = rowInJ %27
                    featureDistance(featureI,featureJ) = featureDistance(featureI,featureJ) + ...
                        featuresCellArray_ordered{featureJ}(rowInJ,2) - featuresCellArray_ordered{featureI}(rowInI,2);
                    featureSquareDistance(featureI,featureJ) = featureSquareDistance(featureI,featureJ) + ...
                        (featuresCellArray_ordered{featureJ}(rowInJ,2) - featuresCellArray_ordered{featureI}(rowInI,2)).^2;
                    twoFeatureOverlap(featureI,featureJ) = twoFeatureOverlap(featureI,featureJ) + 1;
%                     if featureJ  ==  featureI+1
%                         for featureK = featureJ+1:numFeatures
%     %                         featureK = featureI+1;
%                             rowInK = find(featuresCellArray_ordered{featureK}(:,1)  ==  featuresCellArray_ordered{featureI}(rowInI,1));
%                             if ~isnan(rowInK)
%                                 featureDistanceCrossProducts(featureI,featureJ,featureK) = featureDistanceCrossProducts(featureI,featureJ,featureK) + ...
%                                     (featuresCellArray_ordered{featureJ}(rowInJ,2) - featuresCellArray_ordered{featureI}(rowInI,2)) .* ...
%                                     (featuresCellArray_ordered{featureK}(rowInK,2) - featuresCellArray_ordered{featureJ}(rowInJ,2));
%                                 threeFeatureOverlap(featureI,featureJ,featureK) = threeFeatureOverlap(featureI,featureJ,featureK) + 1;
% 
%                             end
%                         end
%                     end
                end


                twoFeatureOverlap(featureJ,featureI) = twoFeatureOverlap(featureI,featureJ);
        %         featureDistances(featureI,featureJ) = featureDistances(featureI,featureJ) ./ featureOverlaps(featureI,featureJ);
        %         featureSquareDistances(featureI,featureJ) = featureSquareDistances(featureI,featureJ) ./ featureOverlaps(featureI,featureJ);
                featureSquareDistance(featureJ,featureI) = featureSquareDistance(featureI,featureJ);
        %         
                featureDistance(featureJ,featureI) = -featureDistance(featureI,featureJ);

        %         featureDistanceVariances(featureI,featureJ) = featureSquareDistances(featureI,featureJ) - featureDistances(featureI,featureJ).^2;
        %         featureDistanceVariances(featureJ,featureI) = featureDistanceVariances(featureI,featureJ);
    
            end


        end
    end
    
%     for featureI = 1:numFeatures
%         for featureJ = featureI+1:numFeatures
%              for featureK = featureJ+1:numFeatures
%                 featureDistanceCrossProducts(featureI,featureK,featureJ) = featureDistanceCrossProducts(featureI,featureJ,featureK);
%                 threeFeatureOverlap(featureI,featureK,featureJ) = threeFeatureOverlap(featureI,featureJ,featureK);
%                 featureDistanceCrossProducts(featureJ,featureI,featureK) = featureDistanceCrossProducts(featureI,featureJ,featureK);
%                 threeFeatureOverlap(featureJ,featureI,featureK) = threeFeatureOverlap(featureI,featureJ,featureK);
%                 featureDistanceCrossProducts(featureJ,featureK,featureI) = featureDistanceCrossProducts(featureI,featureJ,featureK);
%                 threeFeatureOverlap(featureJ,featureK,featureI) = threeFeatureOverlap(featureI,featureJ,featureK);
%                 featureDistanceCrossProducts(featureK,featureI,featureJ) = featureDistanceCrossProducts(featureI,featureJ,featureK);
%                 threeFeatureOverlap(featureK,featureI,featureJ) = threeFeatureOverlap(featureI,featureJ,featureK);
%                 featureDistanceCrossProducts(featureK,featureJ,featureI) = featureDistanceCrossProducts(featureI,featureJ,featureK);
%                 threeFeatureOverlap(featureK,featureJ,featureI) = threeFeatureOverlap(featureI,featureJ,featureK);
%              end
%         end
%     end
    
    toc

    twoFeatureOverlap(logical(eye(size(twoFeatureOverlap)))) = 1;
%     for feature = 1:numFeatures
%         threeFeatureOverlap(feature,feature,feature) = 1;
%     end
    
    

    featureDistance = featureDistance ./ twoFeatureOverlap;
    featureSquareDistance = featureSquareDistance ./ twoFeatureOverlap;
    featureDistanceVariances = featureSquareDistance - featureDistance.^2;
%     featureDistanceCrossProducts = featureDistanceCrossProducts ./ threeFeatureOverlap;
    
    

    minimOverlap = 5;
    
    removalMask = zeros(numFeatures);
    removalMask(twoFeatureOverlap<minimOverlap) = 1;
    removalMask(logical(eye(size(removalMask)))) = 0;
    
    removalMask = logical(removalMask);
    
    featureDistance(removalMask) = NaN;
    featureSquareDistance(removalMask) = NaN;
    featureDistanceVariances(removalMask) = Inf;
    
    featureDistanceVariances(isnan(featureDistanceVariances)) = Inf;
    
%     removalMask = zeros(numFeatures,numFeatures,numFeatures);
%     removalMask(threeFeatureOverlap<minimOverlap) = 1;
%     for feature = 1:numFeatures
%         removalMask(feature,feature,feature) = 0;
%     end
%     removalMask = logical(removalMask);
% %     featureDistanceCrossProducts(removalMask) = NaN;
    
    
    tic;
%     featureGraph=graph();
%     featureGraph=addnode(featureGraph,numFeatures);
%     
%     for featureI = 1:numFeatures
%         for featureJ = featureI+1:numFeatures
%             featureGraph = addedge(featureGraph,featureI,featureJ,featureDistanceVariances(featureI,featureJ));
%         end
%     end
    
    optimalEstimatorMembers = cell(numFeatures);
%     optimalEstimator = cell(numFeatures-1,1);
    optimalEstimatorDistance = zeros(numFeatures);
    optimalEstimatorVariance = zeros(numFeatures);
    displayCells = cell(numFeatures);
    for featureI = 1:numFeatures-1
        for featureJ = featureI+1:min(numFeatures,featureI+5)
    %         optimalEstimatorMembers{featureI} = shortestpath(featureGraph,featureI,featureI+1);
            [optimalEstimatorVariance(featureI,featureJ), optimalEstimatorMembers{featureI,featureJ}, ~] = graphshortestpath(sparse(featureDistanceVariances),featureI,featureJ);

            for featureK = 1:length(optimalEstimatorMembers{featureI,featureJ})-1
                optimalEstimatorDistance(featureI,featureJ) = optimalEstimatorDistance(featureI,featureJ) + ...
                    featureDistance(optimalEstimatorMembers{featureI,featureJ}(featureK) , optimalEstimatorMembers{featureI,featureJ}(featureK+1));

    %             optimalEstimatorVariance(featureI) = optimalEstimatorVariance(featureI) + ...
    %                 featureDistanceVariances(optimalEstimatorMembers{featureI}(featureJ) , optimalEstimatorMembers{featureI}(featureJ+1));
            end
            
            displayCells{featureI,featureJ} = ['Feature ' num2str(featureI) '-' num2str(featureJ) ': '...
                num2str(optimalEstimatorDistance(featureI,featureJ)) ' +- ' num2str(sqrt(optimalEstimatorVariance(featureI,featureJ)))];

%             disp(['Feature ' num2str(featureI) '-' num2str(featureI+1) ': '  num2str(optimalEstimatorDistance(featureI)) ' +- ' num2str(optimalEstimatorVariance(featureI))]);
            
        end
    end
    
    for featureI = 1:numFeatures-1
        for featureJ = featureI+1:min(numFeatures,featureI+3)
            disp(displayCells{featureI,featureJ});
        end
    end
    
    toc;
    
    
%     tic;
%     distanceEstimator = zeros(numFeatures,numFeatures,numFeatures,numFeatures);
%     
%     distanceCovariance = zeros(numFeatures-1);
%     for featureI = 1:numFeatures-1
%         for featureK = 1:numFeatures
%             distanceCovariance(featureI,featureK) = ...
%                 featureDistanceCrossProducts(featureI,featureI+1,featureK) - ...
%                 featureDistance(featureI,featureI+1).*featureDistance(featureI+1,featureK);
%         end
%     end
%     
%     distanceEstimatorVariance = Inf(numFeatures,numFeatures,numFeatures,numFeatures);
%     
%     optimalEstimator = zeros(numFeatures-1,1);
%     optimalEstimatorVar = zeros(numFeatures-1,1);
%     optimalEstimatorIdx = cell(numFeatures-1);
%     
%     for featureI = 1:numFeatures-1
%         for featureJ = 1:numFeatures
%             for featureK = 1:numFeatures
%                 for featureL = 1:numFeatures
% %                     for featureM = featureK+1:numFeatures
% %                         featureM = featureI + 1;
%                         distanceEstimator(featureI,featureJ,featureK,featureL) = ...
%                             featureDistance(featureI,featureJ) + ...
%                             featureDistance(featureJ,featureK) + ...
%                             featureDistance(featureK,featureL) + ...
%                             featureDistance(featureL,featureI+1);
%                         
%                         distanceEstimatorVariance(featureI,featureJ,featureK,featureL) = ...
%                             featureDistanceVariances(featureI,featureJ) + ...
%                             featureDistanceVariances(featureJ,featureK) + ...
%                             featureDistanceVariances(featureK,featureL) + ...
%                             featureDistanceVariances(featureL,featureI+1);
% 
%                 end
%             end
%         end
%                          
%     end
% 
% %     for featureI = 1:numFeatures-1
%         
%        
%     disp('Feature Distances:');
%     for featureI = 1:numFeatures-1
%         distanceEstimatorVarTemp = distanceEstimatorVariance(featureI,:,:,:);
%         [minVariance, minVarIdx] = min(distanceEstimatorVarTemp(:));
%         [~,optimalEstimatorIdx{featureI}(1),optimalEstimatorIdx{featureI}(2),optimalEstimatorIdx{featureI}(3)] = ind2sub([1 numFeatures numFeatures numFeatures],minVarIdx);
%         optimalEstimator(featureI) = distanceEstimator(featureI,optimalEstimatorIdx{featureI}(1),optimalEstimatorIdx{featureI}(2),optimalEstimatorIdx{featureI}(3));
%         optimalEstimatorVar(featureI) = minVariance;
% %         disp([num2str(optimalEstimator(featureI)) ' +- ' num2str(minVariance)]);
%     end
%     
%     featureDistances = optimalEstimator;
%     featureDistVar = optimalEstimatorVar;
%     
%     toc;
    

end
