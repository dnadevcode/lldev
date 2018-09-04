function [] = plot_exp_vs_exp_barcodes_bitmasked( ...
        hAxis, ...
        barcodeIdxA, ...
        barcodeIdxB, ...
        comparisonResults, ...
        consensusBarcodeNames, ...
        stretchedConsensusBarcodes, ...
        stretchedConsensusBitmasks, ...
        eteSettings)
    % Plots the two barcodes specified in box1 and box2.

    barcodeA = stretchedConsensusBarcodes{barcodeIdxA};
    barcodeB = stretchedConsensusBarcodes{barcodeIdxB};
     
    bitmaskA = stretchedConsensusBitmasks{barcodeIdxA};
    bitmaskB = stretchedConsensusBitmasks{barcodeIdxB};
    
    barcodeLenA = length(barcodeA);
    barcodeLenB = length(barcodeB);
    
    stretchFactors = eteSettings.stretchFactors;
    % Stretch barcode A
    usingStretchFactorsTF = not(isempty(stretchFactors) || isequal(stretchFactors, 1));
    if usingStretchFactorsTF
        oldBarcodeLenA = barcodeLenA;
        stretchFactorForAGivenB = stretchFactorsMat(barcodeIdxA, barcodeIdxB);
        barcodeLenA = round(stretchFactorForAGivenB*barcodeLenA);
        barcodeA = interp1(barcodeA,linspace(1,oldBarcodeLenA,barcodeLenA));
    end


    shorterBarcode = barcodeA;
    shorterBarcodeName = barcodeNameA;
    longerBarcode = barcodeB;
    longerBarcodeName = barcodeNameB;
    if (barcodeLenA > barcodeLenB) || ...
      ((barcodeLenB == barcodeLenA) && (barcodeIdxA > barcodeIdxB))
        shorterBarcode = barcodeB;
        shorterBarcodeName = barcodeNameB;

        longerBarcode = barcodeA;
        longerBarcodeName = barcodeNameA;
    end


    % Flip and shift
    if sameLength
        shift = abs(shortShiftMat(barcodeIdxA, barcodeIdxB));
        if flipMat(barcodeIdxA, barcodeIdxB)
            shorterBarcode = fliplr(shorterBarcode);
        end
    else
        lShift = longShiftMat(barcodeIdxA, barcodeIdxB);
        sShift = shortShiftMat(barcodeIdxA, barcodeIdxB);

        longShifted = [longerBarcode(lShift+1:end) longerBarcode(1:lShift)];
        shortShifted = [shorterBarcode(sShift:end) shorterBarcode(1:sShift-1)];
        if flipMat(barcodeIdxA, barcodeIdxB)
            shortShifted = fliplr(shortShifted);
        end
    end

    colorLongerBarcode = [0 0 1];
    colorShorterBarcode = [0 0.5 0];

    longerBarcodeLen = length(longerBarcode);
    shorterBarcodeLen = length(shorterBarcode);

    hold(hAxis, 'on');
    if sameLength
        plot(hAxis, (1:longerBarcodeLen)-1, longerBarcode, ...
            'Color', colorLongerBarcode);
        if (shift + 1) + shorterBarcodeLen > longerBarcodeLen
            plot(hAxis, -1 + ((shift + 1):longerBarcodeLen), shorterBarcode(1:longerBarcodeLen-shift), ...
                'Color', colorShorterBarcode);
            plot(hAxis, -1 + (1:((shift + 1) + shorterBarcodeLen - longerBarcodeLen)), shorterBarcode(longerBarcodeLen-shift:end), ...
                'Color', colorShorterBarcode);
        else
            plot(hAxis, -1 + (1:shorterBarcodeLen) + shift, shorterBarcode, 'Color', colorShorterBarcode);
        end
    else
        plot(hAxis, -1 + (1:length(longShifted)), longShifted, 'Color', colorLongerBarcode);
        plot(hAxis, -1 + (1:length(shortShifted)), shortShifted, 'Color', colorShorterBarcode);
    end
    titleStr = sprintf('CC: %g, P-value: %g', ccVal, pVal);
    hold(hAxis, 'off');
    xlabel(hAxis, 'kbp')
    ylabel(hAxis, 'Rescaled intensity')
    title(hAxis, titleStr);
    legend(hAxis, {longerBarcodeName, shorterBarcodeName}, ...
        'Interpreter', 'none');
    axis(hAxis, 'tight');

    % Change the x-axis labels
    maxPosX = round(longerBarcodeLen * kbpsPerPixel);
    xPos = round(linspace(0, maxPosX, longerBarcodeLen));
    oldTickLabels = get(hAxis, 'XTickLabel');
    oldTicks = cellfun(@str2double, oldTickLabels);
    oldTicks = oldTicks(not(isnan(oldTicks)));
    newTicks = oldTicks;
    newTicks(oldTicks ~= 0) = xPos(oldTicks(oldTicks ~= 0));
    set(hAxis, 'XTickLabel', newTicks)
end