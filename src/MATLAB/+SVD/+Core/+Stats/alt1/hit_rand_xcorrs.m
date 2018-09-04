function [ maxCCs, CCs ] = hit_rand_xcorrs( hit, targetLen, randBarcodeFunction, numRand )
%HIT_RAND_XCORRS A function to find maximum correlation coefficients for
%hits from HMM
%   hit: The hit segment of the query barcode sequence
%   targetLen: length of the target sequence
%   randBarcodeFunction: a handle to a function that returns a 
%       cell array of random barcodes, with the following inputs: 
%       (lengthOfBarcodes, numberOfBarcodes)
%   numRand: Number of random barcodes to generate

    queryMask = true(length(hit), 1);
    targetMask = true(targetLen, 1);
    randBarcodes = randBarcodeFunction(targetLen, numRand);
    
    maxCCs = zeros(1, length(randBarcodes));
    for i = 1:length(randBarcodes)
        CCs = SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs(hit, randBarcodes{i}, queryMask, targetMask);
        maxCCs(i) = max([CCs(:)]);
    end
end

