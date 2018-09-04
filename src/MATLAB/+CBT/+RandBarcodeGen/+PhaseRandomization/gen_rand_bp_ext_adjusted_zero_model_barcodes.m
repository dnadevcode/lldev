function [randomBarcodes] = gen_rand_bp_ext_adjusted_zero_model_barcodes(numRandBarcodes, randBarcodeLen_pixels, meanZeroModelFftFreqMags, zeroModelKbpsPerPixel, barcodeKbpsPerPixel)
    % Random barcodes may need to be made longer/shorter than refLen
    %  to account for different meanBpExt_pixels ratios before
    %   they are stretched to the size of refLen to avoid
    %   frequencies relative to basepairs from being warped 
    %
    %  this relies on the assumption that a pixelized barcode's
    %   frequencies are largely dominated by patterns in fluorescence
    %   which are determined at the basepair level and that any
    %   variance in other factors which effect the frequency
    %   analysis for the barcode are comparitively negligible
    %
    % TODO Note (SQ): Consider the following:
    %  the extent to which the above is fact isn't entirely clear
    %   since other factors like motion of molecules intraframe,
    %   point spread function width, and noisiness of the barcode
    %   are all things one might expect to also have an effect on
    %   the fourier frequencies
    % zeroModel_meanBpExt_pixels/barcode_meanBpExt_pixels
    prestretchLenRatio = barcodeKbpsPerPixel/zeroModelKbpsPerPixel;
    import CBT.RandBarcodeGen.PhaseRandomization.gen_rand_barcodes_stretched_to_len;
    randomBarcodes = gen_rand_barcodes_stretched_to_len(randBarcodeLen_pixels, meanZeroModelFftFreqMags, numRandBarcodes, prestretchLenRatio);
end