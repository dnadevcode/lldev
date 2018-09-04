function [randBarcodes] = gen_rand_barcodes_stretched_to_len(randBarcodeLen_pixels, meanZeroModelFftFreqMags, numRandBarcodes, prestretchLenRatio)
    if nargin < 4
        prestretchLenRatio = 1;
    end

    prestretchReflen = round(randBarcodeLen_pixels * prestretchLenRatio);

    import CBT.RandBarcodeGen.PhaseRandomization.generate_rand_barcodes_from_fft_zero_model;
    randBarcodes = generate_rand_barcodes_from_fft_zero_model(meanZeroModelFftFreqMags, numRandBarcodes, prestretchReflen);

    if not(prestretchReflen == randBarcodeLen_pixels)
        tmpInterpPts = linspace(1, prestretchReflen, randBarcodeLen_pixels);
        randBarcodes = cellfun(@(randomBarcode) interp1(randomBarcode, tmpInterpPts), randBarcodes, 'UniformOutput', false);
    end
end