function [ merged_feature ] = merge_features(featuresCellArray,estimatorMembers,minOverlap)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%     import dotkymoAlignment.*

%     mergeTimer = tic;
    import ELD.Core.calculate_neighbor_distance;
    import ELD.Core.calculate_feature_distances;

    featureA = featuresCellArray{estimatorMembers(1)};
    featureB = featuresCellArray{estimatorMembers(end)};

    merged_feature = vertcat(featureA,featureB);
    [~,sortingRaw] = sort(merged_feature(:,1));
    merged_feature = merged_feature(sortingRaw,:);
        
    overlapA = ismember(featureA(:,1),featureB(:,1));
        
    if any(overlapA)
        
        overlapB = ismember(featureB(:,1),featureA(:,1));
        
        [~,sortingUnique,~] = unique(merged_feature(:,1));
        merged_feature = merged_feature(sortingUnique,:);
        
        feature_len = size(merged_feature,1);
        
        combinedSorting = sortingRaw(sortingUnique);
        
        overlapInMerged = vertcat(overlapA,overlapB);
        overlapInMerged = overlapInMerged(combinedSorting);
        
        if nnz(overlapInMerged) > min(length(featureA),length(featureB))/2
            merged_feature = 0;
            return;
        end
        
        unmergedFeatureArray = nan(feature_len,4);
        
        [~,featureASorting] = ismember(featureA(:,1),merged_feature(:,1));
%         featureAExtended = nan(size(merged_feature));
%         featureAExtended(featureASorting,:) = featureA;
        unmergedFeatureArray(featureASorting,1:2) = featureA;

        [~,featureBSorting] = ismember(featureB(:,1),merged_feature(:,1));
%         featureBExtended = nan(size(merged_feature));
%         featureBExtended(featureBSorting,:) = featureB;
        unmergedFeatureArray(featureBSorting,3:4) = featureB;

%         hor = horzcat(featureAExtended,featureBExtended)
        
        if nnz(overlapInMerged) == 1
            numOverlapRegions = 1;
            overlapIntervals = [find(overlapInMerged) find(overlapInMerged)];
        else
%             overlapIdx = find(overlapInMerged);
            pixStep = diff(overlapInMerged);

            if overlapInMerged(1)
                overlapIntervals(:,1) = [1; find(pixStep == 1)+1'];
            else
                overlapIntervals(:,1) = find(pixStep == 1)+1';
            end

            
            if overlapInMerged(end)
                overlapIntervals(:,2) = [find(pixStep == -1)'; length(overlapInMerged)];
            else
                overlapIntervals(:,2) = find(pixStep == -1)';
            end
            
            numOverlapRegions = size(overlapIntervals,1);
        %     pos = pos((pos > startIdx+1) & (pos < endIdx-1));
        %     pos = pos(pos < endIdx-1);
%             cuts = [cuts, cuts + 1];
%             cuts = sort(cuts);
%             
% %             overlapIntervals = featureA(cuts);
%             overlapIntervals = overlapIdx(cuts)
%             overlapIntervals(:,1) = overlapIntervals(:,1) + 1;
%             overlapIntervals(:,2) = overlapIntervals(:,2) - 1;
        end
        
%         overlapRegions = cell(numOverlapRegions,1);
% %         nonOverlapRegions = cell(numOverlapRegions+1,1);
%         for overlapIdx = 1:numOverlapRegions
% %             nonOverlapRegions{overlapIdx} = [1 intervals(overlapIdx,1)-1];
%             overlapRegions{overlapIdx} = overlapIntervals(overlapIdx,:);
%         end
%         nonOverlapRegions{end} = [intervals(end,1)+1 length(overlapInMerged)];

        numNeighbors = numel(estimatorMembers) - 2;
%         overlapCombinations = nchoosek(1:2,numOverlapRegions);
        
%         numOverlapRegions = 4;
        elements = repmat([1 2], [1 numOverlapRegions]);
        elements = mat2cell(elements,1,repmat(2,[1 numOverlapRegions]));
        overlapCombinations = cell(1, numel(elements)); 
        [overlapCombinations{:}] = ndgrid(elements{:});
        overlapCombinations = cellfun(@(x) x(:), overlapCombinations,'uniformoutput',false);
        overlapCombinations = [overlapCombinations{:}];
 
        numCombinations = size(overlapCombinations,1);
        
        temp_feature = cell(numCombinations,1);
        temp_feature(:) = {merged_feature};
        
        combVariance = zeros(numCombinations,1);
        
        for combAttempt = 1:numCombinations
            
            for overlapRegion = 1:size(overlapCombinations,2)
                
                overlapIdxs = overlapIntervals(overlapRegion,1):overlapIntervals(overlapRegion,2);
                currFeature = overlapCombinations(combAttempt,overlapRegion);
                
                temp_feature{combAttempt}(overlapIdxs,:) = ...
                    unmergedFeatureArray(overlapIdxs,...
                    (currFeature-1)*2+1:(currFeature-1)*2+2);
            end
            
            
            for neighbor = unique([2 numNeighbors+1])
                
%                 featureA = featureA
%                 featureB = featureB
%                 combAttempt = combAttempt
%                 neighbor = neighbor
%                 estimatorMembers = estimatorMembers
                [dist,var] = calculate_neighbor_distance( temp_feature{combAttempt}, featuresCellArray{estimatorMembers(neighbor)}, minOverlap);
      
                if isnan(dist) || isempty(dist)
                    featuresCellArray{end+1} = temp_feature{combAttempt};
                    [dist2, var2 , ~] = calculate_feature_distances( featuresCellArray , [], [], minOverlap);
                    [var, ~, ~] = graphshortestpath(sparse(var2),length(featuresCellArray),estimatorMembers(neighbor));
                    featuresCellArray(end) = [];
                end
                
%                 dist2 = dist2(~isnan(dist2));
%                 dist2 = dist2(1);
%                 
%                 var2 = var2(var2<Inf);
%                 var2=var2(1);
                
                
                
                combVariance(combAttempt) = combVariance(combAttempt) + var;
            end
            
        end
        
        [~,optimalIdx] = min(combVariance);
        
        merged_feature = temp_feature{optimalIdx};

    end
    
%     mergeTime = toc(mergeTimer)
end

