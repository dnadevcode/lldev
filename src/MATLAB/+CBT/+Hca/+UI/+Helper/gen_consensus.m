function [ hcaSessionStruct] = gen_consensus( hcaSessionStruct, sets )
    % gen_consensus - generates consensus
    
    % input hcaSessionStruct, sets
    
    % output consensusStructure
    
    if sets.barcodeConsensusSettings.aborted
        hcaSessionStruct.consensusStruct = [];
        hcaSessionStruct.consensusStruct.Filtered = [];
        display('Skipping consensus generation');
    end
    
    display('Starting generating consensus...')
    tic
        
	sets.barcodeConsensusSettings.commonLength = ceil(mean(hcaSessionStruct.lengths));
    
    
    if sets.prestretchMethod == 0
        import CBT.Consensus.Core.convert_barcodes_to_common_length;
        [rawBarcodes] = convert_barcodes_to_common_length(hcaSessionStruct.rawBarcodes, sets.barcodeConsensusSettings.commonLength);
        import CBT.Consensus.Core.convert_bitmasks_to_common_length;
        [rawBitmasks] = convert_bitmasks_to_common_length(hcaSessionStruct.rawBitmasks, sets.barcodeConsensusSettings.commonLength);
    else
        rawBarcodes = hcaSessionStruct.rawBarcodes;
        rawBitmasks = hcaSessionStruct.rawBitmasks; 
    end
    
    molStruct.rawBarcodes = rawBarcodes;
    molStruct.rawBitmasks = rawBitmasks;
    molStruct.barcodeGen = hcaSessionStruct.barcodeGen;
    import CBT.Hca.Import.generate_consensus;
    hcaSessionStruct.consensusStruct  = generate_consensus( molStruct, sets );

    if  sets.filterSettings.filter == 1
        sets.barcodeConsensusSettings.commonLength2 = ceil(mean(hcaSessionStruct.lengthsFiltered));
         
        if sets.prestretchMethod == 0   %to do: put this in a wrapper function
            import CBT.Consensus.Core.convert_barcodes_to_common_length;
            [rawBarcodes] = convert_barcodes_to_common_length(hcaSessionStruct.rawBarcodesFiltered, sets.barcodeConsensusSettings.commonLength2);
            import CBT.Consensus.Core.convert_bitmasks_to_common_length;
            [rawBitmasks] = convert_bitmasks_to_common_length(hcaSessionStruct.rawBitmasksFiltered, sets.barcodeConsensusSettings.commonLength2);
        else
            rawBarcodes = hcaSessionStruct.rawBarcodesFiltered;
            rawBitmasks = hcaSessionStruct.rawBitmasksFiltered; 
        end

        molStruct.rawBarcodes = rawBarcodes;
        molStruct.rawBitmasks = rawBitmasks;
        molStruct.barcodeGen = hcaSessionStruct.barcodeGenFiltered;
        import CBT.Hca.Import.generate_consensus;
        hcaSessionStruct.consensusStructFiltered = generate_consensus( molStruct, sets );
    end

    timePassed = toc;
    display(strcat(['All consensuses generated in ' num2str(timePassed) ' seconds']));

end

