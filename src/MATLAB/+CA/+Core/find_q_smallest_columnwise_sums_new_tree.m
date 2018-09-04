function [pathMatrix, pathSums, actualBestPathNum] = find_q_smallest_columnwise_sums_new_tree(...
        contigOrder, ...
        clusterContigStateCounts, ...
        nonremovedContigBarcodeLens, ...
        ...
        costLists, ...
        possibleSites, ...
        numPossibleSites, ...
        ...
        numBestPathsQ, ...
        maxLen, ...
        overlapLim, ...
        allowOverlap, ...
        forcePlace ...
    )
    %
    % Finds q smallest column-wise sums in a matrix A
    % with M rows and N columns
    % [column-wise sum: sum_(i=1)^N A(p(i),i) for some "path", p(i)]
    %
    % INPUT:   A = input cell array of cost lists
    %          numBestPathsQ = "q": number of optimal paths required
    %
    % OUTPUT:  pathMatrix = contains the q optimal paths
    %                       (best path in first row)
    %          pathSums = column-wise sums for paths in pathMatrix.
    %
    %  Theoretical computational cost: q N^2 M log (M) [log(q)  + log(N)  - 1]
    %  (for large N).
    %
    % [Sorting requires N M log(M) operations
    %  Rest: sum over new potential path (labeled by r) gives N operations
    %  Looking for overlap with previous paths -- best case (no overlap)
    %  is a binary search in vector of length k*N. This gives log(kN) operations
    %  Total for loop over k: I = N sum_k=1^q log(kN),
    %  replacing sum by integral gives I = N q (log(qN) - 1).
    %  Note: in the estimate above we ignored the cost of
    %  "reshuffling" indexPrime on lines 165 .
    %  One way around this problem is to use doubly linked lists for
    %  indexPrime instead of an array, see
    %  http://se.mathworks.com/help/matlab/matlab_oop/example--implementing-linked-lists.html]
    %
    % Authors:
    %   Tobias Ambjornsson, - 2015
    %   Christoffer Pichler,(modifications) - 2016
    %   Saair Quader, (refactoring) - 2016
    %
    % "Hard-coded" parameters
    %     tol = 1E-12;      % if two numbers, A and B, satisfy |A-B|<tol,
    %                       % then A and B are deemed to be identical
    %                       % (used in binary search algorithm)
    import CA.SortedCollectionManager;
    import Fancy.Utils.data_hash;

    % Derived parameters
    numContigStates = length(costLists);
    numContigs = sum(clusterContigStateCounts);

    numTotalPossiblePaths = prod(numPossibleSites); % paths through an M x N matrix.
    numBestPathsQ = min(numTotalPossiblePaths,numBestPathsQ);
    

    % Assign memory
    optimalPathsMat = zeros(numBestPathsQ,numContigStates); % the q accepted optimal paths through B
    columnWiseSumsByPath = zeros(numBestPathsQ,1); % the q accepted minimum column-wise sums
    sortedList = SortedCollectionManager(@data_hash);
    overlapTestVector = zeros(numContigs,1); % Vector that is used to test if there are any overlaps between contig
    sortedSites = cell(numContigStates,1); % Sorted version of possibleSites

    % --- Initialize ---
    % Sort columns of input lists
    [B, indexCostListSorted] = cellfun(@sort, costLists, 'UniformOutput', false);

    for clusterContigStateCounts = 1:numContigStates
        sortedSites{clusterContigStateCounts} = possibleSites{clusterContigStateCounts}(indexCostListSorted{clusterContigStateCounts},:);
    end

    % --- Find best path ----
    % Best path through the sorted B-matrix
    optimalPathsMat(1,:) = ones(1,numContigStates);

    % Testing if there are overlap
    contigOrderIdx = 0;
    for contigStateNum = 1:numContigStates
        for clusterContigStateNum = 1:clusterContigStateCounts(contigStateNum)
            contigOrderIdx = contigOrderIdx + 1;
            overlapTestVector(contigOrder(contigOrderIdx)) = sortedSites{contigStateNum}(1,clusterContigStateNum);
        end
    end
    import CA.Core.check_placements_for_overlaps;
    numOverlap = check_placements_for_overlaps(overlapTestVector, nonremovedContigBarcodeLens, maxLen, allowOverlap, true, forcePlace);

    % Sum along best path
    currPathSum = 0;
    for clusterContigStateCounts = 1:numContigStates
        currPathSum = currPathSum + B{clusterContigStateCounts}(1);
    end
    columnWiseSumsByPath(1) = currPathSum;
    sortedList.add_entry_with_score(optimalPathsMat(1,:),columnWiseSumsByPath(1));

    % Check overlap
    if sum(numOverlap > overlapLim) == 0
        pathMatrix = overlapTestVector';
        pathSums = columnWiseSumsByPath(1);
        disp('Actual q:')
        disp('1')
        return
    end

    % Calculate column-wise sums for "next" potential paths
    % (labeled by r) by "deforming" best path
    for clusterContigStateCounts=1:numContigStates
        pathTemp = optimalPathsMat(1,:);
        pathTemp(clusterContigStateCounts) = pathTemp(clusterContigStateCounts) + 1;
        if pathTemp(clusterContigStateCounts) <= numPossibleSites(clusterContigStateCounts)
            % sum associated with pathTemp
            currPathSum = columnWiseSumsByPath(1) + B{clusterContigStateCounts}(2) - B{clusterContigStateCounts}(1);
            sortedList.add_entry_with_score(pathTemp,currPathSum)
        end
    end

    % --- Find next q-1 smallest sums ---
    % k labels the optimal paths ( k = 1 , ... , q)
    tmpPathLen = 1;
    for bestPathNum = 2:numBestPathsQ
        % Find the k best path
        if bestPathNum/50000 == floor(bestPathNum/50000)
            toc
            fprintf('Have checked %d solutions\n', bestPathNum)
        end

        if tmpPathLen == 1
            columnWiseSumsByPath(bestPathNum) = sortedList.get_next_lowest_score(columnWiseSumsByPath(bestPathNum-1));
            tmpPath = sortedList.get_entry_values_for_score(columnWiseSumsByPath(bestPathNum));
            tmpPathLen = length(tmpPath);
            optimalPathsMat(bestPathNum,:) = tmpPath{1};
        else
            tmpPathLen = tmpPathLen - 1;
            columnWiseSumsByPath(bestPathNum) = columnWiseSumsByPath(bestPathNum-1);
            optimalPathsMat(bestPathNum,:) = tmpPath{end-tmpPathLen+1};
        end

        % Testing if there are overlap
        contigOrderIdx = 0;
        for contigStateNum = 1:numContigStates
            for clusterContigStateNum = 1:clusterContigStateCounts(contigStateNum)
                contigOrderIdx = contigOrderIdx + 1;
                overlapTestVector(contigOrder(contigOrderIdx)) = sortedSites{contigStateNum}(optimalPathsMat(bestPathNum,contigStateNum),clusterContigStateNum);
            end
        end
        import CA.Core.check_placements_for_overlaps;
        numOverlap = check_placements_for_overlaps(overlapTestVector, nonremovedContigBarcodeLens, maxLen, allowOverlap, true, forcePlace);
        % Stop program if it found a solution with allowed overlap
        if sum(numOverlap > overlapLim) == 0
            break
        end

        for clusterContigStateCounts=1:numContigStates
            % Go through all possible path "deformations" from the just accepted path
            pathTemp = optimalPathsMat(bestPathNum,:);
            pathTemp(clusterContigStateCounts) = pathTemp(clusterContigStateCounts) + 1;
            if pathTemp(clusterContigStateCounts) > numPossibleSites(clusterContigStateCounts)
                continue
            else
                currPathSum = columnWiseSumsByPath(bestPathNum) + B{clusterContigStateCounts}(pathTemp(clusterContigStateCounts)) - B{clusterContigStateCounts}(optimalPathsMat(bestPathNum,clusterContigStateCounts));
            end

            alreadyChecked = sortedList.has_entry(pathTemp);
            if not(alreadyChecked)
                sortedList.add_entry_with_score(pathTemp,currPathSum);
                if currPathSum == columnWiseSumsByPath(bestPathNum)
                    tmpPathLen = tmpPathLen + 1;
                    tmpPath(end + 1) = {pathTemp};
                end
            end
        end
    end
    clear sortedList

    actualBestPathNum = bestPathNum;

    % --- Translate a path in matrix B ---
    % --- into a path in original matrix A ---
    pathMatrix = zeros(1,numContigs);
    contigOrderIdx = 0;
    for contigStateNum = 1:numContigStates
        for clusterContigStateNum = 1:clusterContigStateCounts(contigStateNum)
            contigOrderIdx = contigOrderIdx + 1;
            pathMatrix(contigOrder(contigOrderIdx)) = sortedSites{contigStateNum}(optimalPathsMat(actualBestPathNum,contigStateNum),clusterContigStateNum);
        end
    end
    pathSums = columnWiseSumsByPath(actualBestPathNum);
end