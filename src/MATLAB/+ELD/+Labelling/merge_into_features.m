function [ merged_feature ] = merge_into_features(featuresCellArray,estimatorMembers,minOverlap)
%	Merges two features into one. If the features overlap vertically, the
%	pixels that are selected as belonging to the feature, are those that
%	give the smallest variance in the distances to its neighbors.

%   Input: 
%         featuresCellArray: A cell array containing all features in the
%         kymograph. Each cell contains a n*2 integer array, containing
%         the indices for the position of the feature (each row 
%         corresponding to the position of one pixel belonging to the
%         feature).
%         estimatorMembers: An integer vector containing the indices for
%         the features involved. The first and last feature indices are the
%         features to be merged. The indices in between represent the
%         features involved for getting the best estimator of the feature
%         distance.
%         minOverlap: The minimum vertical overlap (in pixels) between
%         features, for them to be considered truly overlapping. Used for
%         debugging in this function.

%   Output:
%         merged_feature: An array containing the indices for the position 
%         of the new, merged feature. Each row corresponds to the position
%         of one pixel belonging to the feature.

    import ELD.Core.calculate_neighbor_distance;
    import ELD.Core.calculate_feature_distances;

    %Extract the features to be merged.
    featureA = featuresCellArray{estimatorMembers(1)};
    featureB = featuresCellArray{estimatorMembers(end)};

    %Concatenate the features to create a new, merged one.
    merged_feature = vertcat(featureA,featureB);
    [~,sortingRaw] = sort(merged_feature(:,1));
    merged_feature = merged_feature(sortingRaw,:);
        
    %Check if there is any vertical overlap. If not, we are done.
    overlapA = ismember(featureA(:,1),featureB(:,1)); 
    if any(overlapA)
        
        % Find where in the merged feature (in what rows) there are 
        % overlaps, and therefore multiple options for what pixel to chose.
        overlapB = ismember(featureB(:,1),featureA(:,1));
        
        [~,sortingUnique,~] = unique(merged_feature(:,1));
        merged_feature = merged_feature(sortingUnique,:);
        
        feature_len = size(merged_feature,1);
        
        combinedSorting = sortingRaw(sortingUnique);
        
        overlapInMerged = vertcat(overlapA,overlapB);
        overlapInMerged = overlapInMerged(combinedSorting);
        
        %If the overlap is larger then half the length of the smaller
        %feature, they are considered unmergable.
        if nnz(overlapInMerged) > min(length(featureA),length(featureB))/2
            merged_feature = 0;
            return;
        end
        
        %Generate a n*4 array, where the first two columns contains
        %featureA, and he second featureB, arranged so that actual
        %vertically overlapping pixels are displayed in the same rows. 
        unmergedFeatureArray = nan(feature_len,4);
        
        [~,featureASorting] = ismember(featureA(:,1),merged_feature(:,1));

        unmergedFeatureArray(featureASorting,1:2) = featureA;

        [~,featureBSorting] = ismember(featureB(:,1),merged_feature(:,1));

        unmergedFeatureArray(featureBSorting,3:4) = featureB;
        
        %If there is only one overlapping pixel between the features, the 
        %start and end point of the overlap is the same, and therefore 
        %easily identifiable. Otherwise more processing is required.
        if nnz(overlapInMerged) == 1
            numOverlapRegions = 1;
            overlapIntervals = [find(overlapInMerged) find(overlapInMerged)];
        else

            pixStep = diff(overlapInMerged);

            %Find the vertical starting index of every overlap region.
            if overlapInMerged(1)
                overlapIntervals(:,1) = [1; find(pixStep == 1)+1'];
            else
                overlapIntervals(:,1) = find(pixStep == 1)+1';
            end

            %Find the vertical ending index of every overlap region.
            if overlapInMerged(end)
                overlapIntervals(:,2) = [find(pixStep == -1)'; length(overlapInMerged)];
            else
                overlapIntervals(:,2) = find(pixStep == -1)';
            end
            
            %Identify the number of regions where there is overlap.
            numOverlapRegions = size(overlapIntervals,1);

        end

        numNeighbors = numel(estimatorMembers) - 2;

        %Identify all possible combinations of what pieces to select from
        %the two features to be merged. In every region where they overlap,
        %there are two options to chose from - the pixels from featureA or
        %the pixels from featureB. With n overlap regions, there are then
        %2^n possible combinations.
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
        
        %Create a potential feature for each overlap combination.
        for combAttempt = 1:numCombinations
            
            %For each overlap region, select the correct pixels, from the
            %correct feature.
            for overlapRegion = 1:size(overlapCombinations,2)
                
                overlapIdxs = overlapIntervals(overlapRegion,1):overlapIntervals(overlapRegion,2);
                currFeature = overlapCombinations(combAttempt,overlapRegion);
                
                temp_feature{combAttempt}(overlapIdxs,:) = ...
                    unmergedFeatureArray(overlapIdxs,...
                    (currFeature-1)*2+1:(currFeature-1)*2+2);
            end
            
            %Calculate the distances from the potential feature and its
            %neighbors, and the variance of those distances.
            for neighbor = unique([2 numNeighbors+1])

                [dist,var] = calculate_neighbor_distance( temp_feature{combAttempt}, featuresCellArray{estimatorMembers(neighbor)}, minOverlap);
      
                %If the distances could not be readily calculated, all
                %feature distances will have to be recalculated, as well as
                %the variance of the optimal estimator.
                if isnan(dist) || isempty(dist)
                    featuresCellArray{end+1} = temp_feature{combAttempt};
                    [~, var2 , ~] = calculate_feature_distances( featuresCellArray , [], [], minOverlap);
                    [var, ~, ~] = graphshortestpath(sparse(var2),length(featuresCellArray),estimatorMembers(neighbor));
                    featuresCellArray(end) = [];
                end
                
                combVariance(combAttempt) = combVariance(combAttempt) + var;
            end
            
        end
        
        [~,optimalIdx] = min(combVariance);
        
        merged_feature = temp_feature{optimalIdx};

    end

end

