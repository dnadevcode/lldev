function [clustersContigIdxs, contigClusterAssignments] = cluster_contigs(costLists, forcePlacementTF, clusterThreshold)
    % Find which one-contig states to merge into more-contig states

    numCostLists = length(costLists);

    if not(forcePlacementTF)
        for costListNum = 1:numCostLists
            costLists{costListNum} = costLists{costListNum}(1:end-1);
        end
    end

    % Calculate CC matrix
    ccMat = zeros(numCostLists);
    for costListIdxA = 1:(numCostLists - 1)
        for costListIdxB = (costListIdxA + 1):numCostLists
            ccMat(costListIdxB, costListIdxA) = sum(costLists{costListIdxA}.*costLists{costListIdxB});
            if ccMat(costListIdxB, costListIdxA) == 0
                ccMat(costListIdxB, costListIdxA) = 0.001;
            end
        end
    end
    ccVec = 1 ./ (ccMat(ccMat > 0)' + 1);
    cutoff = 1 / (clusterThreshold + 1);

    % perform complete linkage clustering
    Z = linkage(ccVec, 'complete');

    % group the data into clusters
    clusterGroupNums = cluster(Z, 'cutoff', cutoff, 'criterion', 'distance');

    clustersContigIdxs = cell(numCostLists,1);
    contigClusterAssignments = zeros(numCostLists, 1);
    clusteredMask = false(numCostLists, 1);
    removableRedundancyMask = false(numCostLists,1);
    allIdxs = 1:numCostLists;
    currClusterNum = 1;
    for costListNum = 1:numCostLists
        if clusteredMask(costListNum)
            removableRedundancyMask(costListNum) = true;
            continue;
        end
        currClusterMask = (clusterGroupNums(costListNum) == clusterGroupNums);
        clustersContigIdxs{costListNum} = allIdxs(currClusterMask);
        contigClusterAssignments(currClusterMask) = currClusterNum;
        clusteredMask(currClusterMask) = true;
        currClusterNum = currClusterNum + 1;
    end
    clustersContigIdxs(removableRedundancyMask) = [];
end