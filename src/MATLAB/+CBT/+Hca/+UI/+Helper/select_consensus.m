function [ hcaSessionStruct,sets] = select_consensus( hcaSessionStruct, sets )
    % gen_consensus - generates consensus
    
    % input hcaSessionStruct, sets
    
    % output consensusStructure
    
    if sets.barcodeConsensusSettings.aborted
        return;
    end
    if sets.barcodeConsensusSettings.promptForBarcodeClusterLimit == 1
        figure,
        subplot(1,2,1)
        plot(hcaSessionStruct.consensusStruct.treeStruct.maxCorCoef)
        title('Consensus comparison score plot','Interpreter','latex');
        xlabel('Number of averaged barcodes ', 'Interpreter','latex')
        ylabel('Maximal experiment vs experiment score', 'Interpreter','latex')
        if  sets.filterSettings.filter == 1        
            subplot(1,2,2)
            plot(hcaSessionStruct.consensusStructFiltered.treeStruct.maxCorCoef)
            title('Consensus comparison filtered score plot','Interpreter','latex');
            xlabel('Number of averaged barcodes ', 'Interpreter','latex')
            ylabel('Maximal experiment vs experiment score', 'Interpreter','latex')
        end
    end
    import CBT.Consensus.Import.get_cluster_threshold;
    [sets.barcodeConsensusSettings.barcodeClusterLimit, ~] = get_cluster_threshold(sets.barcodeConsensusSettings);

         
    consensusIndex = find(hcaSessionStruct.consensusStruct.treeStruct.maxCorCoef>sets.barcodeConsensusSettings.barcodeClusterLimit,1,'last');
    
    if isempty(consensusIndex)
        disp('All comparisons are below barcode cluster limit');
        return;
    end
    [~,row]=max(sum(hcaSessionStruct.consensusStruct.treeStruct.barMatrix{consensusIndex},2));
    
    hcaSessionStruct.consensusStruct.barcode = hcaSessionStruct.consensusStruct.treeStruct.treeBarcodes{consensusIndex}(row,:);
    hcaSessionStruct.consensusStruct.bitmask = hcaSessionStruct.consensusStruct.treeStruct.treeBitmasks{consensusIndex}(row,:);
    hcaSessionStruct.consensusStruct.name =  hcaSessionStruct.consensusStruct.treeStruct.clusteredBar{row};
    hcaSessionStruct.consensusStruct.indices = find(hcaSessionStruct.consensusStruct.treeStruct.barMatrix{consensusIndex}(row,:));
    disp('Barcodes that are included in the consensus are')
    disp(num2str(hcaSessionStruct.consensusStruct.indices))
    sets.barcodeConsensusSettings.barcodesInConsensus = hcaSessionStruct.consensusStruct.indices;
    if  sets.filterSettings.filter == 1        
        consensusIndex = find(hcaSessionStruct.consensusStructFiltered.treeStruct.maxCorCoef>sets.barcodeConsensusSettings.barcodeClusterLimit,1,'last');
        
        if isempty(consensusIndex)
            disp('All filtered comparisons are below barcode cluster limit');
            return;
        end
        [~,row]=max(sum(hcaSessionStruct.consensusStructFiltered.treeStruct.barMatrix{consensusIndex},2));
        hcaSessionStruct.consensusStructFiltered.barcode = hcaSessionStruct.consensusStructFiltered.treeStruct.treeBarcodes{consensusIndex}(row,:);
        hcaSessionStruct.consensusStructFiltered.bitmask = hcaSessionStruct.consensusStructFiltered.treeStruct.treeBitmasks{consensusIndex}(row,:);            hcaSessionStruct.consensusStruct.name =  hcaSessionStruct.consensusStruct.treeStruct.clusteredBar{row};
        hcaSessionStruct.consensusStructFiltered.name =  hcaSessionStruct.consensusStructFiltered.treeStruct.clusteredBar{row};
        hcaSessionStruct.consensusStructFiltered.indices = find(hcaSessionStruct.consensusStructFiltered.treeStruct.barMatrix{consensusIndex}(row,:));
        disp('Barcodes that are included in the filtered consensus are')
        disp(num2str(hcaSessionStruct.consensusStructFiltered.indices))
        sets.filterSettings.barcodesInConsensus = hcaSessionStruct.consensusStruct.indices;

    end

    timePassed = toc;
    display(strcat(['All consensuses generated in ' num2str(timePassed) ' seconds']));

end

