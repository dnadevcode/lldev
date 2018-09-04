function [maxPCCsAgainstRandBarcodes] = calc_max_PCCs_against_rand_barcodes(barcode, bitmask, randomBarcodes, randomBitmask, stretchFactors)
    % Calculate maximum PCCs
    
    % input barcode, bitmask, randomBarcodes, randomBitmask,
    % stretchFactors
    
    % output maxPCCsAgainstRandBarcodes

    % Generating all the different versions of the experiment
    barcodeLen = length(barcode);
    stretchedBarcodes = arrayfun( ...
        @(stretchedLen) ...
            interp1(barcode, linspace(1, barcodeLen, stretchedLen)), ...
        round(stretchFactors * barcodeLen), ...
        'UniformOutput', false);
    
    stretchedBitmask = cell(1,length(stretchedBarcodes));
    %standartize consensusBitmasks aswell
    for i=1:length(stretchedBarcodes)
        v = linspace(1, length(bitmask), length(stretchedBarcodes{i}));
        stretchedBitmask{i} = bitmask(round(v));
    end 
    
    maxPCCsAgainstRandBarcodes = zeros(length(stretchedBarcodes),length(randomBarcodes));
    for i=1:length(stretchedBarcodes)
        strB = stretchedBarcodes{i};
        strBit = stretchedBitmask{i};
        
        for j=1:length(randomBarcodes)
           xM = zeros(1,length(strB));
           randomBarcode = randomBarcodes{j};
           
           if length(strB) > length(randomBarcode)
                short=randomBarcode;
                long=strB;
                shortB = bitmask;
                longB = strBit;
           else
                short=strB;
                long=randomBarcode;
                shortB = strBit;
                longB = bitmask;
           end
           parfor shift=1:length(short)
               xcorrs = SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs(circshift(short,[0 shift]), long,shortB,longB);
               xM(shift) = max(xcorrs(:));
           end
           
           maxPCCsAgainstRandBarcodes(i,j) = max(xM);
        end     
    end
    maxPCCsAgainstRandBarcodes = maxPCCsAgainstRandBarcodes(:);
end
