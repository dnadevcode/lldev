function [placedContigBarcodes, bestCCs] = find_contig_placements(rescaledContigBarcodes, rescaledConcensusBarcode)
    % Authors:
    %  Erik Lagerstedt
    %  Saair Quaderi (refactoring)
    
    import CA.Old.Core.ccorr_lincirc;

    multipleFiles = length(rescaledContigBarcodes) > 1;
    consensusLen = length(rescaledConcensusBarcode);
    tmpConsensusBarcode = rescaledConcensusBarcode;
    numContigs = length(rescaledContigBarcodes);
    bestCCs = NaN(numContigs, 1);
    stretchFactors = 0.8:0.01:1.2;
    numStretchFactors = length(stretchFactors);
    placedContigBarcodes = cell(size(rescaledContigBarcodes));
    for contigNum = 1:numContigs
        currContigBarcode = rescaledContigBarcodes{contigNum};

        bestStretchFactorCHat = -1;
        bestStretchedBarcode = [];
        ccMatForBest = [];
        flipTFForBest = [];
        for stretchFactorIdx = 1:numStretchFactors
            stretchFactor = stretchFactors(stretchFactorIdx);
            currBarcodeLen = length(currContigBarcode);
            stretchedBarcodeLen = round(stretchFactor*(currBarcodeLen));
            stretchedBarcode = interp1(currContigBarcode,1:(currBarcodeLen - 1)/(stretchedBarcodeLen - 1):currBarcodeLen);
            [ccMatCurr, flipTFCurr] = ccorr_lincirc(tmpConsensusBarcode, stretchedBarcode);
            currCHat = max(ccMatCurr);
            if max(bestStretchFactorCHat, currCHat) > bestStretchFactorCHat
                bestStretchFactorCHat = currCHat;
                bestStretchedBarcode = stretchedBarcode;
                ccMatForBest = ccMatCurr;
                flipTFForBest = flipTFCurr;
            end
        end
        flipTF = flipTFForBest;
        currContigBarcode = bestStretchedBarcode;
        stretchedLen = length(currContigBarcode);

        [bestCC, offset] = max(ccMatForBest);
        if flipTF
            currContigBarcode = fliplr(currContigBarcode);
        end
        currContigBarcode = [NaN(1, offset) currContigBarcode]; %#ok<AGROW>
        if stretchedLen > consensusLen
            currContigBarcode = [currContigBarcode(consensusLen:end) currContigBarcode(((stretchedLen-consensusLen)+1):consensusLen-1)];
        elseif multipleFiles
            currContigBarcode = [currContigBarcode NaN(1, (consensusLen-stretchedLen))]; %#ok<AGROW>
        end
        if multipleFiles
            nonnanPlacementMask = not(isnan(currContigBarcode));
            tmpConsensusBarcode(nonnanPlacementMask) = 0;
        end

        bestCCs(contigNum) = bestCC;
        placedContigBarcodes{contigNum} = currContigBarcode;
    end
end