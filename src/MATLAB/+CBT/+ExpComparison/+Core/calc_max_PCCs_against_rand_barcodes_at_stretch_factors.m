function [maxPCCsAgainstRandBarcodes] = calc_max_PCCs_against_rand_barcodes_at_stretch_factors(barcode, randomBarcodes, stretchFactors)
    % Calculate maximum PCCs

    % Generating all the different versions of the experiment
    barcodeLen = length(barcode);
    stretchedBarcodes = arrayfun( ...
        @(stretchedLen) ...
            interp1(barcode, linspace(1, barcodeLen, stretchedLen)), ...
        round(stretchFactors * barcodeLen), ...
        'UniformOutput', false);
    
    maxPCCsAgainstRandBarcodes = zeros(length(stretchedBarcodes),length(randomBarcodes));
    for i=1:length(stretchedBarcodes)
        strB = stretchedBarcodes{i};
        parfor j=1:length(randomBarcodes)
            maxPCCsAgainstRandBarcodes(i,j) = CBT.ExpComparison.Core.GrossCcorr.ccorr_circcirc(strB, randomBarcodes{j});
        end  
    end
    maxPCCsAgainstRandBarcodes = maxPCCsAgainstRandBarcodes(:);
end
