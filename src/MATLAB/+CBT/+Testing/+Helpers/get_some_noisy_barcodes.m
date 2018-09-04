function [noisyShuffledBarcodes, flipTFs, circShifts, baseBarcode] = get_some_noisy_barcodes(baseBarcode, noiseMagnitude, numBarcodes)
    import CBT.RandBarcodeGen.Reorientation.apply_rand_flip_and_shift;
    import CBT.RandBarcodeGen.Noisification.add_some_noise;

    if nargin < 2
        noiseMagnitude = 0.5;
    end
    if nargin < 3
        numBarcodes = 1;
    end
    noisyShuffledBarcodes = cell(numBarcodes, 1);
    flipTFs = false(numBarcodes, 1);
    circShifts = zeros(numBarcodes, 1);
    for barcodeNum = 1:numBarcodes
        [shuffledBarcode, flipTFs(barcodeNum), circShifts(barcodeNum)] = apply_rand_flip_and_shift(baseBarcode);
        noisyShuffledBarcodes{barcodeNum} = zscore(add_some_noise(shuffledBarcode, noiseMagnitude));
    end
end