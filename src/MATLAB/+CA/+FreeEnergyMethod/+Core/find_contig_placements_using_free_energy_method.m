function [contigPlacementOptionIdxsByBranch, sValsByBranch, numTotalOverlapsByBranch] = find_contig_placements_using_free_energy_method(refBarcode, croppedContigBarcodes, sValsMat, indVecMax, overlapCost, startMat)
    contigBarcodeLens_pixels = cellfun(@length, croppedContigBarcodes);

    numAttempts = prod(indVecMax);

    sValsByBranch = ones(min(numAttempts, 19),1);
    indVec = ones(1,length(croppedContigBarcodes));
    maxSvalBranchIdx = 1;

    contigPlacementOptionIdxsCurrBranch = zeros(1,length(croppedContigBarcodes));
    contigPlacementOptionIdxsByBranch = zeros(size(sValsByBranch,1),length(croppedContigBarcodes));
    numTotalOverlapsByBranch = zeros(size(sValsByBranch,1),1);
    F = zeros(1,length(croppedContigBarcodes));

    refBarcodeLen_pixels = length(refBarcode);
    for attemptNum = 1:numAttempts
        % Get the start positions
        for contigPlacementOptionIdxNum = 1:length(contigPlacementOptionIdxsCurrBranch)
            contigPlacementOptionIdxsCurrBranch(contigPlacementOptionIdxNum) = startMat(contigPlacementOptionIdxNum, indVec(contigPlacementOptionIdxNum));
        end

        % Calculate the energy part
        for croppedContigBarcodeNum = 1:length(croppedContigBarcodes)
            F(croppedContigBarcodeNum) = -2*log(sValsMat(croppedContigBarcodeNum,contigPlacementOptionIdxsCurrBranch(croppedContigBarcodeNum)));
        end

        % Calculate the entropy (overlap)
        startTemp = contigPlacementOptionIdxsCurrBranch;
        startTemp(startTemp>refBarcodeLen_pixels) = startTemp(startTemp>refBarcodeLen_pixels) - refBarcodeLen_pixels;
        stopTemp = startTemp + contigBarcodeLens_pixels-1;
        overlap = zeros(1,2*refBarcodeLen_pixels);
        for croppedBarcodeNum = 1:length(croppedContigBarcodes)
            overlap(startTemp(croppedBarcodeNum):stopTemp(croppedBarcodeNum)) = overlap(startTemp(croppedBarcodeNum):stopTemp(croppedBarcodeNum)) + ones(1,contigBarcodeLens_pixels(croppedBarcodeNum));
        end
        overlap(1:refBarcodeLen_pixels) = overlap(1:refBarcodeLen_pixels)+overlap(refBarcodeLen_pixels+(1:refBarcodeLen_pixels));
        numOverlap = sum(overlap(overlap(1:refBarcodeLen_pixels)>1));

        % Calculate total s-value
        sTotTemp = 1 - chi2cdf(sum(F)- (overlapCost)*numOverlap, 2*length(F));
        if sTotTemp < sValsByBranch(maxSvalBranchIdx)
            sValsByBranch(maxSvalBranchIdx) = sTotTemp;
            contigPlacementOptionIdxsByBranch(maxSvalBranchIdx,:) = contigPlacementOptionIdxsCurrBranch;
            numTotalOverlapsByBranch(maxSvalBranchIdx) = numOverlap;
            [~, maxSvalBranchIdx] = max(sValsByBranch);
        end

        % Update index vector
        for idxIdx = 1:length(indVec)
            if (indVec(idxIdx) + 1 <= indVecMax(idxIdx))
                indVec(idxIdx) = indVec(idxIdx) + 1;
                break;
            end

            if attemptNum == numAttempts
                break;
            end
            indVec(idxIdx) = 1;
        end
        
    end
end