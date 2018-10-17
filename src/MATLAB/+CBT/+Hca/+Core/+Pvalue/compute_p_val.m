function [ hcaSessionStruct ] = compute_p_val(pvalData, hcaSessionStruct )

    % maximum p-values
    cMaxVals = cellfun(@(x) x.maxcoef(1), hcaSessionStruct.comparisonStructure);
    % length of theory barcodes
    barLen = cellfun(@(x) sum(x) ,hcaSessionStruct.rawBitmasks);
    
    if length(barLen) < length(cMaxVals)
       barLen(end+1) = sum(hcaSessionStruct.consensusStruct.bitmask);
    end
    % stretch factors
    strFac =hcaSessionStruct.sets.barcodeConsensusSettings.stretchFactors;
    % theory length
    %thrLen = sum(cellfun(@(x) length(x), hcaSessionStruct.theoryGen.theoryBarcodes));

    [ p, cal ] = CBT.Hca.Core.Pvalue.compute_p_val_score(cMaxVals, pvalData, barLen,strFac );

    hcaSessionStruct.pValueResults.pValueMatrix = p;
    hcaSessionStruct.pValueResults.pValueCalculated = cal;              

    try 
        cMaxVals = cellfun(@(x) x.maxcoef(1), hcaSessionStruct.comparisonStructureFiltered);
        [ p, cal ] = CBT.Hca.Core.Pvalue.compute_p_val_score(cMaxVals, pvalData, barLen,strFac );
        hcaSessionStruct.pValueResults.pValueMatrixFiltered = p;
        hcaSessionStruct.pValueResults.pValueFilteredCalculated = cal; 
    catch
    end


end

