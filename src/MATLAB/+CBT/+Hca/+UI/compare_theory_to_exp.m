function [hcaSessionStruct] = compare_theory_to_exp(hcaSessionStruct, sets )
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
            
    hcaSessionStruct.comparedStructure = cell(1,length(hcaSessionStruct.theoryGen.theoryBarcodes));
    %%%%%%%%%%%%%%%%%   
    % unfiltered comparison
    for barNr = 1:length(hcaSessionStruct.theoryGen.theoryBarcodes)
        disp(strcat(['comparing to theory barcode ' hcaSessionStruct.theoryGen.theoryNames{barNr}] ));

        import CBT.Hca.UI.Helper.on_compare_theory_to_exp;
        hcaSessionStruct.comparedStructure{barNr} = on_compare_theory_to_exp(rawBarcodes,rawBitmasks, hcaSessionStruct.theoryGen.theoryBarcodes{barNr},hcaSessionStruct.theoryGen.bitmask{barNr},sets);
    end
    
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
        hcaSessionStruct.comparedStructureFiltered = cell(1,length(hcaSessionStruct.theoryGen.theoryBarcodes));
        for barNr = 1:length(hcaSessionStruct.theoryGen.theoryBarcodes)
            disp(strcat(['comparing to theory barcode ' hcaSessionStruct.theoryGen.theoryNames{barNr}] ));

            if sets.filterSettings.filterMethod == 0 
                hcaSessionStruct.comparedStructureFiltered{barNr} = on_compare_theory_to_exp(rawBarcodes,rawBitmasks, hcaSessionStruct.theoryGen.theoryBarcodes{barNr},hcaSessionStruct.theoryGen.bitmask{barNr},sets,1);   
            else  
                hcaSessionStruct.comparedStructureFiltered{barNr} = on_compare_theory_to_exp(rawBarcodes,rawBitmasks, hcaSessionStruct.theoryGen.theoryBarcodes{barNr},hcaSessionStruct.theoryGen.bitmask{barNr},sets);   
            end
        end
         
        timePassed = toc;
        disp(strcat(['Filtered experiments were compared to theory in ' num2str(timePassed) ' seconds']));
    end
    

end

