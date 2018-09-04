function [hcaSessionStruct] = compare_theory_to_exp_least_squares(hcaSessionStruct, sets )
    % the main function to compare fragments of human chromosome vs. theory
    
    % input hcaSessionStruct, sets 
    
    % output comparisonStructure? (move it outside hcaSessionStruct?)
        
    disp('Starting comparing exp to theory...')
    tic
    
    rawBarcodes = hcaSessionStruct.rawBarcodes;
    rawBitmasks = hcaSessionStruct.rawBitmasks;
    if sets.barcodeConsensusSettings.aborted==0
        rawBarcodes = [rawBarcodes; hcaSessionStruct.consensusStruct.barcode];
        rawBitmasks = [rawBitmasks hcaSessionStruct.consensusStruct.bitmask];
    end
            
    %%%%%%%%%%%%%%%%%   
    % unfiltered comparison
    import CA.CombAuc.UI.Helper.on_compare_theory_to_exp_least_squares
    hcaSessionStruct.comparisonStructure = on_compare_theory_to_exp_least_squares(rawBarcodes,rawBitmasks, hcaSessionStruct.theorySeq,hcaSessionStruct.bitmask,sets);

    timePassed = toc;
    disp(strcat(['Experiments were compared to theory in ' num2str(timePassed) ' seconds']));

    
    % filtered comparison
    if sets.filterSettings.filter==1

        rawBarcodes = hcaSessionStruct.rawBarcodesFiltered;
        rawBitmasks = hcaSessionStruct.rawBitmasksFiltered;
        if sets.barcodeConsensusSettings.aborted==0
            rawBarcodes = [rawBarcodes; hcaSessionStruct.consensusStructFiltered.barcode];
            rawBitmasks = [rawBitmasks hcaSessionStruct.consensusStructFiltered.bitmask];
        end
        disp('Starting comparing filtered exp to theory...')
        tic
        if sets.filterSettings.filterMethod == 0 
            hcaSessionStruct.comparisonStructureFiltered = on_compare_theory_to_exp_least_squares(rawBarcodes,rawBitmasks, hcaSessionStruct.theorySeq,hcaSessionStruct.bitmask,sets,1);   
        else  
            hcaSessionStruct.comparisonStructureFiltered = on_compare_theory_to_exp_least_squares(rawBarcodes,rawBitmasks, hcaSessionStruct.theorySeq,hcaSessionStruct.bitmask,sets);   
        end
         
        timePassed = toc;
        disp(strcat(['Filtered experiments were compared to theory in ' num2str(timePassed) ' seconds']));
    end
    

end

