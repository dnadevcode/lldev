function [outputCC, flipTF, shift] = ccorr_lincirc(barcodeA, barcodeB)
    % CCORR_LINCIRC - Cross-correlation between two barcodes (using local
    % rescaling) where the shorter barcode is assumed to be linear and the
    % longer barcode is circular.
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
    %   barcodeA
    %   barcodeB
    %
    % Outputs: 
    %   outputCC
    %     list of cross-correlation for correct flip
    % flip
    %    0 if no flip, 1 otherwise
    % shift = shift of B1 w r t B2 
    %  [Note that shift can be negative: -(n-1)<=shift<=n-1 ]
    % 
    % Dependencies (matlab-functions, MAT-files): none
    %
    % Authors:
    %   Tobias Ambjörnsson
    %   Christoffer Pichler
    %   Erik Lagerstedt
    %


    %  Store longest input-barcode in the vector longVec 
    %  and the shortest input-barcode in vector shortVec 
    %  Reisner-rescale the shortest barcode  
    %  (the longer one is rescaled while calculating 
    %   the cross-correlation values)  
    barcodeLenA = length(barcodeA);
    barcodeLenB = length(barcodeB);
    barcodeLenShort = min(barcodeLenB, barcodeLenA);
    barcodeLenLong = max(barcodeLenB, barcodeLenA);
    if barcodeLenLong == barcodeLenA
        barcodeLong = barcodeA;
        barcodeShort = barcodeB;
    else
        barcodeLong = barcodeB;
        barcodeShort = barcodeA;
    end;

    %  Reisner-rescale the shortest barcode
    barcodeShort = zscore(barcodeShort);
    barcodeShortFlipped = fliplr(barcodeShort);


    %  Calculate forward and backward cross-correlations 
    %  by "sliding" one barcode across the other 
    barcodeLongSubsequence = zeros(1,barcodeLenShort);
    ccForward = zeros(1,barcodeLenLong);
    ccBackward = zeros(1,barcodeLenLong);


    for pixelIdx = 1:barcodeLenLong
        %  circularly permutate and "cut out"
        %  the relevant part of the longest vector
        %  (the cut out part is of the same length as the shortest barcode;
        if (pixelIdx + barcodeLenShort) > barcodeLenLong
            barcodeLongSubsequence(1:barcodeLenLong-pixelIdx+1) = barcodeLong(pixelIdx:end);
            barcodeLongSubsequence(barcodeLenLong-pixelIdx+2:end) = barcodeLong(1:barcodeLenShort-end+pixelIdx-1);
        else
            barcodeLongSubsequence = barcodeLong(pixelIdx:barcodeLenShort+pixelIdx-1);
        end
        %longVec_perm_cut
        %  Reisner-rescale the permutated and cut-out barcode
        barcodeLongSubsequence=(barcodeLongSubsequence-mean(barcodeLongSubsequence))/std(barcodeLongSubsequence);

        %  calculate forward and backward cross-correlation values
        ccForward(pixelIdx) = sum(barcodeShort.*barcodeLongSubsequence);
        ccBackward(pixelIdx) = sum(barcodeShortFlipped.*barcodeLongSubsequence);
    end

    %  Normalize by the length of the shortest original   
    %  barcodes and identify the direction and cut position
    %  of the shorter barcode w r t the longer one  

    ccForward = ccForward/(barcodeLenShort - 1);
    ccBackward = ccBackward/(barcodeLenShort - 1);
    [maxCCForward, indexForward] = max(ccForward);
    [maxCCBackward, indexBackward] = max(ccBackward);

    flipTF = (maxCCBackward > maxCCForward);
    if flipTF
        outputCC = ccBackward;
        shift = indexBackward - 1;
    else
        outputCC = ccForward;
        shift = indexForward - 1;
    end
    if barcodeLenA == barcodeLenLong
        shift = -shift;
    end
    flipTF = double(flipTF);
end