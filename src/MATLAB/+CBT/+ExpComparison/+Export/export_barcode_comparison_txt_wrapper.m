function [] = export_barcode_comparison_txt_wrapper(...
        barcodeIdxA, ...
        barcodeIdxB, ...
        barcodes, ...
        barcodeNames, ...
        kbpsPerPixel, ...
        sValMat, ...
        maxPCCsMat, ...
        flipMat, ...
        shortShift, ...
        longShift, ...
        stretchFactorsMat, ...
        stretchFactors, ...
        sameLengthTF ...
        )
    % Save two barcodes as a text file


    %---Prepare the barcodes---
    % BC - BarCode number

    barcodeA = barcodes{barcodeIdxA};
    barcodeB = barcodes{barcodeIdxB};

    barcodeNameA = barcodeNames{barcodeIdxA};
    barcodeNameB = barcodeNames{barcodeIdxB};

    barcodeLenA = length(barcodeA);
    barcodeLenB = length(barcodeB);

    % Stretch barcode A
    stretchFactorForAGivenB = 1.0;
    usingStretchFactorsTF = not(isempty(stretchFactors) || isequal(stretchFactors, 1));
    if usingStretchFactorsTF
        oldBarcodeLenA = barcodeLenA;
        stretchFactorForAGivenB = stretchFactorsMat(barcodeIdxA, barcodeIdxB);
        barcodeLenA = round(stretchFactorForAGivenB * barcodeLenA);
        barcodeA = interp1(barcodeA,linspace(1, oldBarcodeLenA, barcodeLenA));
    end
    ccAB = maxPCCsMat(barcodeIdxA, barcodeIdxB);
    pValAB = sValMat(barcodeIdxA, barcodeIdxB);


    shorterBarcode = barcodeA;
    longerBarcode = barcodeB;
    longerBarcodeIdx = barcodeIdxB;
    if (barcodeLenA > barcodeLenB) || ...
      ((barcodeLenB == barcodeLenA) && (barcodeIdxA > barcodeIdxB))
        shorterBarcode = barcodeB;

        longerBarcode = barcodeA;
        longerBarcodeIdx = barcodeIdxA;
    end


    % Flip and shift and pad with zeros
    if sameLengthTF
        shift = abs(shortShift(barcodeIdxA,barcodeIdxB));
        if flipMat(barcodeIdxA,barcodeIdxB)
            shorterBarcode = fliplr(shorterBarcode);
        end
        shorterBarcode = [zeros(1,shift) shorterBarcode zeros(1,length(longerBarcode)-length(shorterBarcode)-shift)];
        if length(shorterBarcode) > length(longerBarcode)
            difference = length(shorterBarcode)-length(longerBarcode);
            shorterBarcode(1:difference) = shorterBarcode(end-difference+1:end);
            shorterBarcode(end-difference+1:end) = [];
        end
        shorterBarcodeShifted = shorterBarcode;
        longerBarcodeShifted = longerBarcode;
    else
        lShift = longShift(barcodeIdxA, barcodeIdxB);
        sShift = shortShift(barcodeIdxA, barcodeIdxB);

        longerBarcodeShifted = [longerBarcode(lShift+1:end) longerBarcode(1:lShift)];
        shorterBarcodeShifted = [shorterBarcode(sShift:end) shorterBarcode(1:sShift-1)];
        if flipMat(barcodeIdxA, barcodeIdxB)
            shorterBarcodeShifted = fliplr(shorterBarcodeShifted);
        end
        shorterBarcodeShifted = [shorterBarcodeShifted zeros(1, length(longerBarcodeShifted) - length(shorterBarcodeShifted))];
    end
    if longerBarcodeIdx == barcodeIdxA
        barcodeShiftedA = longerBarcodeShifted;
        barcodeShiftedB = shorterBarcodeShifted;
    else
        barcodeShiftedA = shorterBarcodeShifted;
        barcodeShiftedB = longerBarcodeShifted;
    end

    %---Write content of the file---
    % Write header

    import CBT.ExpComparison.Export.export_barcode_comparison_txt;
    export_barcode_comparison_txt(...
        barcodeNameA, ...
        barcodeNameB, ...
        sameLengthTF, ...
        stretchFactorForAGivenB, ...
        kbpsPerPixel, ...
        pValAB, ...
        ccAB, ...
        longerBarcodeShifted, ...
        barcodeShiftedA, ...
        barcodeShiftedB ...
        );
end