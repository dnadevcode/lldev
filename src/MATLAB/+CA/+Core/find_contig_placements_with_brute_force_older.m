function [potentialContigPlacementsList, currClusterMergedCostList] =  find_contig_placements_with_brute_force_older(costLists, possibleSites, numPossibleSites, contigLengths, numPlacementOptions, forcePlacementTF, overlapLim)
    % Merge N contigs into a N-contig state. Use brute force method to
    % calculate the cost at each combination of contig placement.

    allowOverlapTF = overlapLim > 0;
            
    numCostLists = length(costLists); %Number of contigs to merge
    if numCostLists == 0
        fprintf('No contig cost lists were provided for contig assembly'); %TODO: improve
    end
    numIterations = prod(numPossibleSites);

    potentialContigPlacementsList = zeros(numIterations,numCostLists);
    currClusterMergedCostList = zeros(numIterations,1);
    hasTooMuchOverlapMask = false(numIterations,1);

    % First iteration
    overlapCheckVec = ones(numCostLists,1);
    for costListNum = 1:numCostLists
        overlapCheckVec(costListNum) = possibleSites{costListNum}(1);
    end
    import CA.Core.check_placements_for_overlaps;
    numOverlap = check_placements_for_overlaps(overlapCheckVec, contigLengths, numPlacementOptions, allowOverlapTF, true, forcePlacementTF);
    hasTooMuchOverlapMask(1) = sum(numOverlap > overlapLim) > 0;

    % Save the indices and cost
    costSum = 0;
    for costListNum = 1:numCostLists
        costSum = costSum + costLists{costListNum}(1);
    end
    potentialContigPlacementsList(1,:) = overlapCheckVec;
    currClusterMergedCostList(1) = costSum;

    % The rest of the iterations
    idxs = ones(numCostLists,1);
    import CA.Core.check_placements_for_overlaps;
    for iterationNum = 2:numIterations
        costSum = currClusterMergedCostList(iterationNum-1);
        % Update indVec

        for currContigIdx = 1:length(possibleSites)
            currPossibleSites = possibleSites{currContigIdx};
            if not(idxs(currContigIdx) == numPossibleSites(currContigIdx))
                break;
            end
            idxs(currContigIdx) = 1;

            overlapCheckVec(currContigIdx) = currPossibleSites(1);
            costSum = costSum + costLists{currContigIdx}(1) - costLists{currContigIdx}(end);
        end

        idxs(currContigIdx) = idxs(currContigIdx) + 1;

        overlapCheckVec(currContigIdx) = currPossibleSites(idxs(currContigIdx));
        costSum = costSum + costLists{currContigIdx}(idxs(currContigIdx)) - costLists{currContigIdx}(idxs(currContigIdx)-1);

        numOverlap = check_placements_for_overlaps(overlapCheckVec, contigLengths, numPlacementOptions, allowOverlapTF, true, forcePlacementTF);
        hasTooMuchOverlapMask(iterationNum) = sum(numOverlap > overlapLim) > 0;

        potentialContigPlacementsList(iterationNum,:) = overlapCheckVec;
        currClusterMergedCostList(iterationNum) = costSum;
    end

    currClusterMergedCostList(hasTooMuchOverlapMask) = [];
    potentialContigPlacementsList(hasTooMuchOverlapMask,:) = [];
    disp('Length after merge:')
    disp(length(currClusterMergedCostList))
end