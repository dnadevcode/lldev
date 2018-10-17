function featuresCellArray=process_peak_graph(peakGraph,sizeThreshold)
%This function takes a directed acyclic graph with a node representing
% the local maximas of an image and it's corresponding edges to other
% nodes represent connections to other local maximas within it's vicinity
% defined by the parameter 'k' as mentioned before.
% It then finds the connected components in the graph which would represent
% a potential feature and then does a topological sort on the nodes
% to make sure that the nodes are in the order of them being
% discovered. (In this case a depth first search would give the same
% result as a topological sort).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%REMOVE ALL THE FAULTY EDGES TO A NODE%

%TODO: handle cases when both the predecessor nodes are equidistant from
%the node with faulty inDegree.


nodeNamesTable=peakGraph.Nodes;
nodeNamesCellArr=nodeNamesTable.Name;

inDegreeArr=indegree(peakGraph);
faultyIndegreeIndx=find(inDegreeArr>1);
faultyNodeNames_cellArr=arrayfun(@(k) nodeNamesCellArr{k},faultyIndegreeIndx,'UniformOutput',false);
predecessorNodeNames_cellArr=cellfun(@(nodeName) predecessors(peakGraph,nodeName),faultyNodeNames_cellArr,'uniformOutput',false);
predecessorNodeNumber_cellArr=cellfun(@(nameCell)  arrayfun(@(k) str2double(nameCell{k}),1:length(nameCell)),predecessorNodeNames_cellArr,'UniformOutput',false);
for i=1:length(faultyNodeNames_cellArr)
    nodeNumber=str2double(faultyNodeNames_cellArr{i});
    diffArr=abs(predecessorNodeNumber_cellArr{i}-nodeNumber);  %Implicit Expansion in MATLAB
    [~,indx]=sort(diffArr);
    peakGraph=rmedge(peakGraph,predecessorNodeNames_cellArr{i}(indx(2:end)),faultyNodeNames_cellArr{i});
%     peakGraph=rmnode(peakGraph,predecessorNodeNames_cellArr{i}(indx(2:end)));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%REMOVE THE COMPONENTS WITH SIZE LESS THAN THE INPUT THRESHOLD%

connectedComponentCellArray=conncomp(peakGraph,'Outputform','cell','type','weak');
size_connectedComponentCellArray=cellfun(@(connectedComponentCell) length(connectedComponentCell),connectedComponentCellArray);
thresholdedFeaturesCellArray=connectedComponentCellArray(size_connectedComponentCellArray>sizeThreshold);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DO A TOPLOGICAL SORT ON THE GRAPH TO GET THEIR CORRESPONDING ORDER IN THE IMAGE%

[~,sortedGraphsCellArray]=cellfun(@(featuresCell) toposort(subgraph(peakGraph,featuresCell)),thresholdedFeaturesCellArray,'uniformOutput',false);
sortedNodesTableCellArray=cellfun(@(sortedGraphs) sortedGraphs.Nodes, sortedGraphsCellArray,'uniformOutput',false);
featuresTableCellArray=cellfun(@(connectedNodesTable) rowfun(@(nodeNumberInString) str2double(nodeNumberInString),connectedNodesTable)...
    ,sortedNodesTableCellArray,'uniformoutput',false);
featuresCellArray=cellfun(@(nodesTable) nodesTable.Var1,featuresTableCellArray,'uniformoutput',false);
end




