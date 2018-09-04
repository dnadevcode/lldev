function [depFilePaths, depSparseMatrix, pathToProductDepsMap] = get_dependency_data(startEntryCommand)
    % GET_DEPENDENCY_GRAPH - builds a directed acyclic graph of
    %  dependencies for a command
    %
    % Inputs:
    %   startEntryCommand
    %     the initial command
    %
    % Outputs:
    %   depFilePaths
    %     cell array of dependency filepaths
    %   depSparseMatrix
    %     sparse matrix containing filepath dependency data
    %   pathToProductDepsMap
    %     containers.Map mapping filepaths to product dependencies
    
    nodeIdxToPathMap = containers.Map('KeyType', 'uint64', 'ValueType', 'char');
    nodePathToDepIdxsMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
    pathToProductDepsMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
    startEntryPath = which(startEntryCommand);
    nodeIdx = uint64(1);
    nodeIdxToPathMap(nodeIdx) = startEntryPath;
    nodePathToDepIdxsMap(startEntryPath) = {nodeIdx, uint64([])};
    
    numNodePaths = numel(keys(nodePathToDepIdxsMap));
    depFilePaths = arrayfun(@(nodeIdx) nodeIdxToPathMap(nodeIdx), (1:numNodePaths)', 'UniformOutput', false);
    totalEdges = 0;
    while nodeIdx <= numNodePaths
        nodePath = nodeIdxToPathMap(nodeIdx);
        [depEntries, pList] = matlab.codetools.requiredFilesAndProducts(nodePath, 'toponly');
        pathToProductDepsMap(nodePath) = pList;
        depEntries = depEntries(:);
        numDepEntries = numel(depEntries);
        totalEdges = totalEdges + numDepEntries;
        [newPathEntries, newEntryDiffIdxs] = setdiff(depEntries, depFilePaths);
        newEntryMask = false(numDepEntries, 1);
        newEntryMask(newEntryDiffIdxs) = true;
        oldEntryDeps = depEntries(~newEntryMask);
        numNewEntries = numel(newPathEntries);
        newPathIdxs = uint64(numNodePaths + (1:numNewEntries)');
        for newEntryNum=1:numNewEntries
            newNodeIdx = newPathIdxs(newEntryNum);
            newNodePath = newPathEntries{newEntryNum};
            nodeIdxToPathMap(newNodeIdx) = newNodePath;
            nodePathToDepIdxsMap(newNodePath) = {newNodeIdx, uint64([])};
        end
        currEntryVal = nodePathToDepIdxsMap(nodePath);
        [~, oldPathIdxs] = intersect(depFilePaths, oldEntryDeps);
        oldPathIdxs = uint64(oldPathIdxs(:));
        edgeIdxs = [oldPathIdxs; newPathIdxs];
        edgeIdxs = setdiff(edgeIdxs, nodeIdx);
        currEntryVal{2} = edgeIdxs;
        nodePathToDepIdxsMap(nodePath) = currEntryVal;
        numNodePaths = numel(keys(nodePathToDepIdxsMap));
        depFilePaths = arrayfun(@(nodeIdx) nodeIdxToPathMap(nodeIdx), (1:numNodePaths)', 'UniformOutput', false);
        nodeIdx = nodeIdx + 1;
    end
    depSparseMatrix = zeros(totalEdges, 2);
    depFilePaths = arrayfun(@(nodeIdx) nodeIdxToPathMap(nodeIdx), (1:numNodePaths)', 'UniformOutput', false);
    lastEdgeNum = 0;
    for nodeIdx = 1:numNodePaths
        nodeEdgesOut = nodePathToDepIdxsMap(depFilePaths{nodeIdx});
        edgeIdxs = double(nodeEdgesOut{2});
        numNewEdges = size(edgeIdxs, 1);
        depSparseMatrix(lastEdgeNum + (1:numNewEdges), :) = [repmat(nodeIdx, [numNewEdges, 1]), edgeIdxs];
        lastEdgeNum = lastEdgeNum + numNewEdges;
    end
    depSparseMatrix = depSparseMatrix(1:lastEdgeNum,1:2);
    depSparseMatrix = sparse(depSparseMatrix(:,1), depSparseMatrix(:,2), 1, numNodePaths, numNodePaths);
end