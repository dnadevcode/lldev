function [potentialContigPlacementsList, currClusterMergedCostList] =  find_contig_placements_with_brute_force(contigItemsInCluster, numPlacementOptions, forcePlacementTF, allowOverlap, overlapLim)
    % Merge N contigs into a N-contig state. Use brute force method to
    % calculate the cost at each combination of contig placement.

    numContigsInCluster = length(contigItemsInCluster); %Number of contigs to merge
    
    contigLengths = [contigItemsInCluster.barcodeLen]';
    numIterations = prod([contigItemsInCluster.numPossibleSites]);

    potentialContigPlacementsList = zeros(numIterations, numContigsInCluster);
    currClusterMergedCostList = zeros(numIterations, 1);
    tooMuchOverlapMask = false(numIterations, 1);

    % First iteration
    overlapCheckVect = ones(numContigsInCluster,1);
    for clusterContigNum = 1:numContigsInCluster
        overlapCheckVect(clusterContigNum) = contigItemsInCluster(clusterContigNum).possibleSites(1);
    end
    import CA.Core.check_placements_for_overlaps;
    allowFlippingTF = true;
    numOverlap = check_placements_for_overlaps(...
        overlapCheckVect, ...
        contigLengths, ...
        numPlacementOptions, ...
        allowOverlap, ...
        allowFlippingTF, ...
        forcePlacementTF);
    tooMuchOverlapMask(1) = sum(numOverlap > overlapLim) > 0;

    % Save the indices and cost
    costSum = 0;
    for clusterContigNum = 1:numContigsInCluster
        currContig = contigItemsInCluster(clusterContigNum);
        costSum = costSum + currContig.costList(1);
    end
    potentialContigPlacementsList(1,:) = overlapCheckVect;
    currClusterMergedCostList(1) = costSum;

    % The rest of the iterations
    placementsIdxVect = ones(numContigsInCluster,1);
    for iterationNum = 2:numIterations
        costSum = currClusterMergedCostList(iterationNum-1);

        for clusterContigNum = 1:numContigsInCluster
            currContig = contigItemsInCluster(clusterContigNum);
            if not(placementsIdxVect(clusterContigNum) == currContig.numPossibleSites)
                break;
            end

            placementsIdxVect(clusterContigNum) = 1;

            overlapCheckVect(clusterContigNum) = currContig.possibleSites(1);
            additionalCost = currContig.costList(1) - currContig.costList(end);
            costSum = costSum + additionalCost;
        end

        placementsIdxVect(clusterContigNum) = placementsIdxVect(clusterContigNum) + 1;

        contigPlacementIdx = placementsIdxVect(clusterContigNum);
        overlapCheckVect(clusterContigNum) = currContig.possibleSites(contigPlacementIdx);
        additionalCost = currContig.costList(contigPlacementIdx) - currContig.costList(contigPlacementIdx - 1);
        costSum = costSum + additionalCost; 


        numOverlap = check_placements_for_overlaps(...
            overlapCheckVect, ...
            contigLengths, ...
            numPlacementOptions, ...
            allowOverlap, ...
            true, ...
            forcePlacementTF ...
        );
        tooMuchOverlapMask(iterationNum) = sum(numOverlap > overlapLim) > 0;

        potentialContigPlacementsList(iterationNum,:) = overlapCheckVect;
        currClusterMergedCostList(iterationNum) = costSum;
    end

    currClusterMergedCostList(tooMuchOverlapMask) = [];
    potentialContigPlacementsList(tooMuchOverlapMask,:) = [];
end