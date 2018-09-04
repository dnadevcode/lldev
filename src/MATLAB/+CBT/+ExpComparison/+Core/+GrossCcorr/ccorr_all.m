function [betterDirCCs, worseDirCCs, flip, shiftOfARelToB] = ccorr_all(...
    barcodeA, ...
    barcodeB, ...
    longerBarcodeIsCircularTF, ...
    shouldRescaleTF ...
)
    % ccorr_all - Even though it might say all, it is actually only for
    % lincirc and linlin.
    %
    %  Calculates the cross-correlation values
    %  between two barcodes. One barcode is slided across the other one
    %  and a set of cross-correlation values are obtain. LOCAL Resiner-rescaling
    %  is used, i.e. the parts of the barcodes being compared
    %  are rescaled to have mean = 0 and standard deviation = 1.
    %  The relative orientation of the barcodes
    %  is also identified (by maximizing the cross-correlation)
    %
    % Inputs:
    %   barcodeA = barcode A
    %   barcodeB = barcode B
    %   longerBarcodeIsCircularTF = false iff the longer barcode is not circular
    %   shouldRescaleTF = false iff the barcodes should not be rescaled
    %
    % Outputs:
    %   betterDirCCs = list of cross-correlation for correct flip
    %   worseDirCCs = rest of the cross-correlation values
    %   flip = 1 if betterDirCCs corresponds to a match with a
    %              barcode flipped relative to other barcode
    %          0 otherwise
    %   shiftOfARelToB = shift of barcode A relative to barcode B
    %           in the range from [-(K - 1), (K - 1)] where
    %            K is length of longer barcode if
    %              longerBarcodeIsCircularTF is true
    %            or 1 + the difference of the barcode lengths
    %              otherwise
    %
    % Authors:
    %   Saair Quaderi
    %   Tobias Ambjörnsson
    %   Christoffer Pichler
    %   Erik Lagerstedt


    %  Store longest input-barcode in the vector longVec
    %  and the shortest input-barcode in vector shortVec
    %  Reisner-rescale the shortest barcode
    %  (the longer one is rescaled while calculating
    %   the cross-correlation values)
    barcodeLenA = length(barcodeA);
    barcodeLenB = length(barcodeB);
    needleBarcodeLen = min(barcodeLenB, barcodeLenA);
    haystackBarcodeLen = max(barcodeLenB, barcodeLenA);
    barcodeBIsNotLonger = (haystackBarcodeLen == barcodeLenA);
    if barcodeBIsNotLonger
        haystackBarcode = barcodeA;
        needleBarcode = barcodeB;
    else
        haystackBarcode = barcodeB;
        needleBarcode = barcodeA;
    end

    if shouldRescaleTF
        %  Reisner-rescale the shortest barcode
        needleBarcode = zscore(needleBarcode);
    end


    %  Calculate forward and backward cross-correlations
    %  by "sliding" one barcode across the other
    numOffsets = haystackBarcodeLen;
    if not(longerBarcodeIsCircularTF)
        numOffsets = numOffsets - needleBarcodeLen + 1;
    end

    ccMat = NaN(2, numOffsets);
    coverageLenMat = needleBarcodeLen + zeros(size(ccMat));

    haystackSegmentIdxs = (1:needleBarcodeLen) - 1;  % same length as shorter barcode
    shorterBarcodeFlipped = fliplr(needleBarcode);
    for offsetIdx = 1:numOffsets
        if longerBarcodeIsCircularTF
            %  adjust any newly circularly wrapped index in preparation
            %   for sliding
            %todo note: this could be sped up using dynamic programming
            haystackSegmentIdxs(haystackSegmentIdxs == haystackBarcodeLen) = 0;
        end
        haystackSegmentIdxs = haystackSegmentIdxs + 1; % slide

        haystackSegment = haystackBarcode(haystackSegmentIdxs);
        if shouldRescaleTF
            %  Reisner-rescale the permutated and cut-out barcode
            haystackSegment = zscore(haystackSegment); %todo note: this could be sped up quite a bit using dynamic programming
        end
        %  Calculate forward and backward cross-correlation values
        ccNonflipped = sum(needleBarcode .* haystackSegment);
        ccFlipped = sum(shorterBarcodeFlipped .* haystackSegment);

        ccMat(1:2, offsetIdx) = [ccNonflipped, ccFlipped];
    end
    ccMat = ccMat ./ (coverageLenMat - 1);

    %  Normalize by the length of the shortest original
    %  barcodes and identify the direction and cut position
    %  of the shorter barcode w r t the longer one

    [maxUnflippedCC, idxUnflippedMax] = max(ccMat(1, :));
    [maxFlippedCC, idxFlippedMax] = max(ccMat(2, :));
    idxsDirMax = [idxUnflippedMax; idxFlippedMax];

    flipTF = (maxFlippedCC > maxUnflippedCC);
    flip = double(flipTF); %TODO: see if we can make this output as logical
    betterDirCCs = ccMat(1 + flip, :);
    worseDirCCs = ccMat(2 - flip, :);

    shiftOfARelToB = (idxsDirMax(1 + flip) - 1) * sign(.5 - double(barcodeBIsNotLonger));
end