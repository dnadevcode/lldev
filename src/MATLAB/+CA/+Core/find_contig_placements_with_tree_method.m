function [contigOrderingsMat, startMat, sValsByBranch, coverageByBranch, flippedMat] = find_contig_placements_with_tree_method(scaledRefBarcode, croppedContigBarcodes, bpsPerPixel, sValueThreshold, isPlasmidTF, contigsShareSameDirTF, isFullyCoveredTF, lowerBoundRef)
    % Assembles contigs by looking at s-value of each contig
    % placement and exploring the different combinations of
    % placement that avoid contig overlap in the form of a tree
    %
    %
    % Problems:
    % Time of completion = 0.1 * N! + 3 seconds

    croppedBarcodeLens = cellfun(@length, croppedContigBarcodes);
    [maxCroppedBarcodeLen_px, largestContigBarcodeIdx] = max(croppedBarcodeLens);


    % Rescale all the contigs
    if isFullyCoveredTF
        tempCurve = zeros(1,length(scaledRefBarcode));
        j = 1;
        for placedContigNum = 1:length(croppedContigBarcodes)
            tempCurve(j:j+length(croppedContigBarcodes{placedContigNum})-1) = croppedContigBarcodes{placedContigNum};
            j = j + length(croppedContigBarcodes{placedContigNum});
        end
        tempCurve(tempCurve==0) = [];
        meanRR = mean(tempCurve);
        stdRR = std(tempCurve);
        for placedContigNum = 1:length(croppedContigBarcodes)
            croppedContigBarcodes{placedContigNum} = (croppedContigBarcodes{placedContigNum}-meanRR)/stdRR;
        end
    end

    % Determine direction assuming that the largest contig will be
    % placed and has highest correlation with reference barcode
    % in the correct direction
    if (contigsShareSameDirTF)
        largestContigBarcode = croppedContigBarcodes{largestContigBarcodeIdx};
        import CBT.ExpComparison.Core.GrossCcorr.ccorr_all_based_flipcheck;
        flipContigsTF = ccorr_all_based_flipcheck(...
            scaledRefBarcode, ...
            largestContigBarcode, ...
            isPlasmidTF, ...
            not(isFullyCoveredTF) ...
        );
        if flipContigsTF
            croppedContigBarcodes = cellfun(@fliplr, croppedContigBarcodes, 'UniformOutput', false);
        end
    end


    initRemovedContigs = zeros(1,length(croppedContigBarcodes));
    initRemainingContigIdxs = 1:length(croppedContigBarcodes);


    % Determine EVD parameters
    import CA.Core.make_fn_gen_gumbel_params_wrapper;
    [failMsg, fn_gen_gumbel_params_wrapper] = make_fn_gen_gumbel_params_wrapper(...
        length(scaledRefBarcode), ...
        maxCroppedBarcodeLen_px, ...
        bpsPerPixel, ...
        isPlasmidTF ...
    );
    if any(failMsg)
        disp(failMsg);
        return;
    end
    [gumbelCurveMus, gumbelCurveBetas] = cellfun(fn_gen_gumbel_params_wrapper, croppedContigBarcodes(:));

    % Allocating memory
    numContigs = length(croppedContigBarcodes);
    numPossibleContigOrderings = factorial(numContigs);
    contigOrderingsMat = zeros(numPossibleContigOrderings, numContigs);
    branchVec = ones(1, numContigs);
    branchLevel = numContigs - 1;
    if branchLevel < 1
        branchLevel = 1;
    end
    sValsByBranch = zeros(1, numPossibleContigOrderings);
    coverageByBranch = zeros(1, numPossibleContigOrderings); % in percent
    startMat = zeros(numPossibleContigOrderings, numContigs);
    stopMat = zeros(numPossibleContigOrderings, numContigs);
    flippedMat = false(numPossibleContigOrderings, numContigs);
    
    %---Main loop---
    for possibleContigOrderingNum = 1:numPossibleContigOrderings
        remainingContigIdxs = initRemainingContigIdxs;
        removedContigs = initRemovedContigs;
        iRemoved = 1;
        sMin = ones(1, numContigs);
        start = zeros(1, numContigs);
        stop = zeros(1, numContigs);

        % Tracks what parts of the refCurve that already is occupied by a contig
        occupied = false(1, length(scaledRefBarcode));

        % Index that keeps track of the number of confirmed and kept contigs
        keptIdx = 1;

        %---Making one branch in the Tree---
        while ~isempty(remainingContigIdxs)
            % Three columns of sValue
            % 1, sValue
            % 2, Optimal position
            % 3, On which refPart
            % 4, Contig index
            % 5, flipped
            sValue = ones(length(remainingContigIdxs), 5);
            sValue(:, 4) = remainingContigIdxs;

            %---Place (remaining) contigs on the (remaining) barcode---
            refPart = cell(1,keptIdx);
            partLength = zeros(1,keptIdx);
            refPartPos = zeros(1,keptIdx);
            if keptIdx == 1 && isPlasmidTF
                refPart{1} = [scaledRefBarcode scaledRefBarcode];
                partLength = 2 * length(scaledRefBarcode);
                refPartPos = 1;
            elseif keptIdx == 1
                refPart{1} = scaledRefBarcode;
                partLength = length(scaledRefBarcode);
                refPartPos = 1;
            else
                % Finds each of the refCurve parts not occupied by a contig
                j = 1;
                for i = 1:length(refPart)
                    if j > length(occupied)
                        break
                    end
                    while j < length(occupied)+1 && occupied(j)
                        j = j + 1;
                    end
                    % Records the start position of the refPart
                    refPartPos(i) = j;
                    while j < length(occupied)+1 && ~occupied(j)
                        partLength(i) = partLength(i) + 1;
                        j = j + 1;
                    end
                    refPart{i} = scaledRefBarcode(refPartPos(i):j-1);
                end

                % Makes the last refPart a part of the first refPart. Only works on
                % circular DNA
                if isPlasmidTF
                    if not(occupied(1)) && not(occupied(end))
                        tempPartLength = partLength(partLength~=0);
                        refPart{1} = [refPart{length(tempPartLength)} refPart{1}];
                        partLength(1) = partLength(1) + tempPartLength(end);
                        refPartPos(1) = refPartPos(length(tempPartLength));
                        refPart(length(tempPartLength)) = [];
                        partLength(length(tempPartLength)) = [];
                        refPartPos(length(tempPartLength)) = [];
                    end
                end

                % Removes empty refParts
                for i = fliplr(1:length(refPart))
                    if length(refPart{i}) < lowerBoundRef
                        refPart(i) = [];
                        partLength(i) = [];
                        refPartPos(i) = [];
                    end
                end
                if isempty(refPart)
                    break
                end
            end

            %---Finds the best position for each (remaining) contig on the refCurve---
            import CBT.ExpComparison.Core.calculate_p_value;
            import CBT.ExpComparison.Core.GrossCcorr.ccorr_all;
            if (contigsShareSameDirTF)
                for j = 1:length(remainingContigIdxs)
                    ccMat = -1.2*ones(length(refPart),max(partLength));
                    contigNum = remainingContigIdxs(j);
                    for refLocIdx = 1:length(refPart)
                        if length(croppedContigBarcodes{contigNum}) > length(refPart{refLocIdx})
                            continue;
                        end
                        [cc1, cc2, flipped] = ccorr_all(...
                            refPart{refLocIdx}, ...
                            croppedContigBarcodes{contigNum}, ...
                            0, ...
                            not(isFullyCoveredTF));
                        if flipped
                            ccMat(refLocIdx,1:length(cc2)) = cc2;
                        else
                            ccMat(refLocIdx,1:length(cc1)) = cc1;
                        end
                    end
                    [bestCCVec,optPosVec] = max(ccMat,[],2);
                    [bestCC,optPart] = max(bestCCVec);
                    gumbelCurveMu = gumbelCurveMus(contigNum);
                    gumbelCurveBeta = gumbelCurveBetas(contigNum);
                    sValue(j,1) = calculate_p_value(gumbelCurveMu, gumbelCurveBeta, bestCC);
                    sValue(j,2) = optPosVec(optPart);
                    sValue(j,3) = optPart;
                end
            else
                flipped = false(1,length(refPart));
                for j = 1:length(remainingContigIdxs)
                    ccMat = -1.2*ones(length(refPart),2*max(partLength));
                    contigNum = remainingContigIdxs(j);
                    for refLocIdx = 1:length(refPart)
                        if length(croppedContigBarcodes{contigNum}) > length(refPart{refLocIdx})
                            continue;
                        end
                        [cc1,cc2,flipped(refLocIdx)] = ccorr_all(...
                            refPart{refLocIdx}, ...
                            croppedContigBarcodes{contigNum}, ...
                            0, ...
                            not(isFullyCoveredTF) ...
                        );
                        ccMat(refLocIdx,1:length([cc1 cc2])) = [cc1 cc2];
                    end
                    [bestCCVec, optPosVec] = max(ccMat,[],2);
                    [bestCC, optPart] = max(bestCCVec);
                    gumbelCurveMu = gumbelCurveMus(contigNum);
                    gumbelCurveBeta = gumbelCurveBetas(contigNum);
                    sValue(j,1) = calculate_p_value(gumbelCurveMu, gumbelCurveBeta, bestCC);
                    sValue(j,2) = optPosVec(optPart);
                    sValue(j,3) = optPart;
                    sValue(j,5) = flipped(optPart);
                end
            end

            % Removes all contigs with too high s-value
            removalMask = sValue(:,1) >= sValueThreshold;
            numRemovals = sum(removalMask);
            indVec = sValue(removalMask,4);
            removedContigs(end-sum(removedContigs==0)+(1:numRemovals)) = indVec;
            iRemoved = iRemoved + numRemovals;
            sValue(removalMask,:) = [];
            remainingContigIdxs(removalMask) = [];
            if length(remainingContigIdxs) < branchVec(keptIdx)
                for iLeft = 1:length(remainingContigIdxs)
                    iRemoved = iRemoved + 1;
                end
                break
            end

            % Sort s-values from lowest to highest
            sValue = sortrows(sValue);

            % Choose contig and save position
            sMin(keptIdx) = sValue(branchVec(keptIdx),1);
            contigOrderingsMat(possibleContigOrderingNum,keptIdx) = sValue(branchVec(keptIdx),4);
            if not(contigsShareSameDirTF)
                flippedMat(possibleContigOrderingNum,keptIdx) = sValue(branchVec(keptIdx),5);
            end
            start(keptIdx) = refPartPos(sValue(branchVec(keptIdx),3))+sValue(branchVec(keptIdx),2)-1;
            stop(keptIdx) = start(keptIdx) + length(croppedContigBarcodes{sValue(branchVec(keptIdx),4)})-1;
            if stop(keptIdx) > length(scaledRefBarcode)
                stop(keptIdx) = stop(keptIdx) - length(scaledRefBarcode);
                if start(keptIdx) > length(scaledRefBarcode)
                    start(keptIdx) = start(keptIdx) - length(scaledRefBarcode);
                    occupied(start(keptIdx):stop(keptIdx)) = true;
                else
                    occupied(start(keptIdx):end) = true;
                    occupied(1:stop(keptIdx)) = true;
                end
            else
                occupied(start(keptIdx):stop(keptIdx)) = true;
            end
            remainingContigIdxs(remainingContigIdxs==contigOrderingsMat(possibleContigOrderingNum,keptIdx)) = [];
            keptIdx = keptIdx + 1;
        end

        % Save vectors into matrices
        startMat(possibleContigOrderingNum,:) = start;
        stopMat(possibleContigOrderingNum,:) = stop;
        coverageByBranch(possibleContigOrderingNum) = round(100*sum(occupied)/length(occupied));

        %---Calculate total s-value---
        if keptIdx > 1
            F = zeros(1,keptIdx-1);
            for iF = 1:length(F)
                F(iF) = -log(sMin(iF));
            end
            F(isinf(F)) = 10;
            sValsByBranch(possibleContigOrderingNum) = 1-chi2cdf(sum(F),2*length(F));
            %---The commented section is an attempt of having removed contigs contribute to s-value---
            %         F = zeros(1,length(contig));
            %         for iF = 1:keptInd-1
            %             F(iF) = -2*log(sMin(iF));
            %         end
            %         jF = 1;
            %         for iF = keptInd:length(contig)
            %             F(iF) = -2*log(sValRemoved(jF));
            %             if F(iF) > 4.6
            %                 F(iF) = 4.6;
            %             end
            %             jF = jF + 1;
            %         end
            %         sTot(iMain) = 1-chi2cdf(sum(F),2*length(F));
        else
            sValsByBranch(possibleContigOrderingNum) = 1;
        end

        % Choose a new branch
        while branchLevel > 1 && branchVec(branchLevel) > length(croppedContigBarcodes) - branchLevel
            branchLevel = branchLevel - 1;
        end
        branchVec(branchLevel) = branchVec(branchLevel) + 1;
        branchVec(branchLevel+1:end) = 1;
        branchLevel = length(croppedContigBarcodes) - 1;
    end
end
