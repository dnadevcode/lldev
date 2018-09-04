function [failMsg, fn_gen_gumbel_params_wrapper] = make_fn_gen_gumbel_params_wrapper(refLen_pixels, desiredBarcodeCropLen_px, barcodeBpsPerPixel, isPlasmidTF)
    barcodeKbpsPerPixel = barcodeBpsPerPixel/1000;

    zeroModelRandSeqsLen_bps = round(desiredBarcodeCropLen_px*barcodeBpsPerPixel);
    import CA.Import.prompt_zero_model_info;
    [zeroModelKbpsPerPixel, meanZeroModelFftFreqMags] = prompt_zero_model_info(zeroModelRandSeqsLen_bps, barcodeGenSettings);
    failMsg = isempty(zeroModelKbpsPerPixel);
    if failMsg
        failMsg = 'Cannot generate gumbel params without a zero model';
        fn_gen_gumbel_params_wrapper = @(barcode) error(failMsg);
        return; 
    end

   % Generate the random barcodes:
    import CBT.RandBarcodeGen.PhaseRandomization.gen_rand_bp_ext_adjusted_zero_model_barcodes;
    numRandBarcodes = 1000;
    randomBarcodes = gen_rand_bp_ext_adjusted_zero_model_barcodes(numRandBarcodes, refLen_pixels, meanZeroModelFftFreqMags, zeroModelKbpsPerPixel, barcodeKbpsPerPixel);

    function [gumbelCurveMu, gumbelCurveBeta] = gen_gumbel_params_wrapper(barcode)


        import CBT.ExpComparison.Core.fit_gumbel_with_zero_model;
        [gumbelCurveMu, gumbelCurveBeta] = fit_gumbel_with_zero_model(...
            barcode, ...
            randomBarcodes, ...
            [], ...
            false, ...
            isPlasmidTF, ...
            true);
    end
    fn_gen_gumbel_params_wrapper = @gen_gumbel_params_wrapper;
end