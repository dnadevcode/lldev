function phaseRandomizedBarcode = phase_randomize_barcode(barcode, randomizedBarcodeLen)
    %Creates a single phase randomized barcode from a single input barcode
    
    if nargin < 2
        randomizedBarcodeLen = length(barcode);
    end
    
    meanZeroModelFftFreqMags = abs(fft(barcode));
    
    import CBT.RandBarcodeGen.PhaseRandomization.generate_rand_barcodes_from_fft_zero_model;
    phaseRandomizedBarcodes = generate_rand_barcodes_from_fft_zero_model(meanZeroModelFftFreqMags, 1, randomizedBarcodeLen);
    phaseRandomizedBarcode = phaseRandomizedBarcodes{1};
end