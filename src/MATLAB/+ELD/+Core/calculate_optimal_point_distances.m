function [ pairArray, distanceArray, matchMetric] = calculate_optimal_point_distances( dataSetA, dataSetB )

    import ELD.Core.calculate_coupled_point_distances;

%     dataSetA = [1, 2, 3, 7, 8, 10];
%     dataSetB = [2.5, 3.5 6 8];
%     dataSetB = [dataSetB, 9, 8.1];
    
    dataSetA = sort(dataSetA);
    dataSetB = sort(dataSetB);
    
%     dataSetA = dataSetA(1:5);
%     dataSetB = dataSetB(1:4);

    numPointsA = numel(dataSetA);
    numPointsB = numel(dataSetB);
    
    if numPointsA == numPointsB
        pairArray = 1:numPointsA;
        
        [distanceArray, matchMetric] = ...
            calculate_coupled_point_distances(dataSetA, dataSetB, pairArray);
        
        return;
    elseif numPointsA > numPointsB
%         tempDataSet = dataSetA;
%         dataSetA = dataSetB;
%         dataSetB = tempDataSet;
%         clear tempDataSet;
        
        [dataSetA, dataSetB] = deal(dataSetB, dataSetA);
        
%         tempNumPoints = numPointsA;
%         numPointsA = numPointsB;
%         numPointsB = tempNumPoints;
%         clear tempNumPoints;   
        
        [numPointsA, numPointsB] = deal(numPointsB, numPointsA);
    end
    
%     pointDistances = nan(numPointsA,numPointsB);
%     for pointAidx = 1:numPointsA
%         pointDistances(pointAidx,:) = dataSetA(pointAidx) - dataSetB;
%     end
    
%     pointDistancesA = dataSetA(:) - dataSetB(:);


    import ELD.Core.point_match_dots;
    [pairArray, distanceArray, matchMetric] = point_match_dots(dataSetA, dataSetB);

    
%     pointDistancesAB = dataSetA - dataSetB';
%     pointDistancesABSquared = pointDistancesAB.^2;
%        
% %     returnDistances = nan(size(pointDistancesSquared));
% %     returnDistances(:) = 1;
%     returnDistVal = min(pointDistancesABSquared(:))/(numPointsA+numPointsB)/100;
%     
%     nodesSourceAB = repmat((1:numPointsA)',1,numPointsB);
% %     nodesB = repmat(1:numPointsB,numPointsA,1);
%     nodesSourceBA = repmat(numPointsA+1:numPointsA+numPointsB,numPointsA,1);
%     
% %     nodesSourceAA = repmat(1:numPointsA,numPointsA-1,1);
% %     nodesSourceAA_2 = nodesSourceAA;
% %     for shiftRow = 1:numPointsA-1
% %         nodesSourceAA_2(shiftRow,:) = circshift(nodesSourceAA(shiftRow,:),shiftRow);
% %     end
% %         
% %     nodesSourceBB = repmat(numPointsA+1:numPointsA+numPointsB,numPointsB-1,1);
% %     nodesSourceBB_2 =  nodesSourceBB;
% %     for shiftRow = 1:numPointsB-1
% %         nodesSourceBB_2(shiftRow,:) = circshift(nodesSourceBB(shiftRow,:),shiftRow);
% %     end
%     
% %     remove_diagonal = @(t)reshape(t(~diag(ones(1,size(t, 1)))), size(t)-[1 0]);
% %     pointSourceAA_2 = remove_diagonal(pointSourceAA');
% %     pointSourceBB_2 = remove_diagonal(pointSourceBB);
%         
%     networkGraph = graph();
%     networkGraph = networkGraph.addnode(numPointsA+numPointsB);
%     networkGraph = networkGraph.addedge(nodesSourceAB, nodesSourceBA, pointDistancesABSquared);
%     for nodeInA = 2 : 2 : numPointsA-1
% %         for nodeInA_2 = nodeInA_1+1 : numPointsA
% %             networkGraph = networkGraph.addedge(nodeInA_1, nodeInA_2, returnDistVal);
%         networkGraph = networkGraph.addedge(nodeInA, nodeInA+1, returnDistVal);
% %         networkGraph = networkGraph.addedge(nodesSourceAA, nodesSourceAA_2, returnDistVal);
% %         end
%     end
%     
%     for nodeInB_1 = numPointsA+1 : numPointsA+numPointsB-1
%         for nodeInB_2 = nodeInB_1+1 : numPointsA+numPointsB
%             networkGraph = networkGraph.addedge(nodeInB_1, nodeInB_2, returnDistVal);
% %         networkGraph = networkGraph.addedge(nodesSourceAA, nodesSourceAA_2, returnDistVal);
%         end
% %         networkGraph = networkGraph.addedge(nodeInB, nodeInB+1, returnDistVal);
%     end
%     
% %     networkGraph = networkGraph.addedge(nodesSourceBB, nodesSourceBB_2, returnDistVal);
%     
% %     networkGraph = networkGraph.addedge(nodesSourceB, nodesSourceA, returnDistances);
%     
%     figure, p = plot(networkGraph,'EdgeLabel',networkGraph.Edges.Weight);
%     
% %     distanceGraph = graph(sparse(pointDistancesSquared));
% 
%     a = graphshortestpath(networkGraph);
% 
%     tic;
%     minimumSpanningTree = minspantree(networkGraph);
%     time = toc;
%     
%     highlight(p,minimumSpanningTree);
    
%     pointDistancesC = arrayfun(@(a,b) dataSetA(a)-dataSetB(b), 1:numPointsA, 1:numPointsB, 'UniformOutput', false);
    
%     possibleCouplingPoints = 1:numPointsB;
%     possibleCombinations = nchoosek(possibleCouplingPoints,numPointsA);
%     
%     numCombinations = size(possibleCombinations,1);
%     distanceArray = cell(numCombinations,1);
%     matchMetric = nan(numCombinations,1);
%     for combination = 1:numCombinations
%         [distanceArray{combination}, matchMetric(combination)] = ...
%             calculate_coupled_point_distances(dataSetA, dataSetB, possibleCombinations(combination,:));
%     end
%     
%     [matchMetric,optIdx] = min(matchMetric);
%     pairArray = possibleCombinations(optIdx,:);
%     distanceArray = distanceArray{optIdx};
%     
% %     [~,order] = sort([numPointsA, numPointsB]);
% %     [numPointsA, numPointsB] = 
    
end

