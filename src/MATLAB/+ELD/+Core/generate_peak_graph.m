function peakGraph=generate_peak_graph(imgArr,k,peakBitMap)
%This function gives a directed graph in which all nodes correspond to the local
%maxima and are connected to only one node(if available) below them(the closest one) within a window of
%(2k+1) pixels centered at the parent node.  The node name is the string
%version of the linearIndex of the pixels that the node corresponds to.


imgSize=size(imgArr);
cols=imgSize(2);
peakIndices=find(peakBitMap);
linearMap=zeros(imgSize);
linearMap(peakIndices)=peakIndices;
[peakRows,peakColumns]=find(linearMap);
lastRowsIndices=(peakRows==imgSize(1));
peakRows(lastRowsIndices)=[];
peakColumns(lastRowsIndices)=[];
getdaughterNodesArr=@(i,j) nonzeros(linearMap(i+1,max(1,j-k):min(j+k,cols)));
[daughterNodesArr,parentNodesArr]=arrayfun(@(i,j) deal(getDaughterNode(i,j),linearMap(i,j)),peakRows,peakColumns,'UniformOutput',false);
numberOfDaughterConnections=arrayfun(@(i) length(daughterNodesArr{i}), 1:length(daughterNodesArr));
zeroConnectionIndices=(numberOfDaughterConnections==0);
daughterNodesArr(zeroConnectionIndices)=[];
parentNodesArr(zeroConnectionIndices)=[];
daughterRow=vertcat(daughterNodesArr{:});
parentRow=vertcat(parentNodesArr{:});
getNodeName=@(nodeNumber) num2str(nodeNumber);
daughterRowNames=arrayfun(getNodeName,daughterRow,'Uniformoutput',false);
parentRowNames=arrayfun(getNodeName,parentRow,'Uniformoutput',false);
peakGraph=digraph(parentRowNames,daughterRowNames);



    function daughterNode=getDaughterNode(i,j)
        daughterNodesArr=getdaughterNodesArr(i,j);
        [~,indx]=min(abs(daughterNodesArr-repmat(linearMap(i,j),length(daughterNodesArr),1)));
        daughterNode=daughterNodesArr(indx);
    end
end

