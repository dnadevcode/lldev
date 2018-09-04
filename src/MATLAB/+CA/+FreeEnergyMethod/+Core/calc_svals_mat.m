function [sValsMat] = calc_svals_mat(refBarcode, croppedContigBarcodes, ccValsUnflipped, ccValsFlipped, fn_gen_gumbel_params_wrapper)
    [gumbelCurveMus, gumbelCurveBetas] = cellfun(fn_gen_gumbel_params_wrapper, croppedContigBarcodes(:));
    refBarcodeLen_pixels = length(refBarcode);
    sValsMat = ones(length(croppedContigBarcodes), 2*refBarcodeLen_pixels);
    idxRangeUnflipped = 1:refBarcodeLen_pixels;
    idxRangeFlipped = refBarcodeLen_pixels + idxRangeUnflipped;
    import CBT.ExpComparison.Core.calculate_p_value;
    numContigs2 = length(croppedContigBarcodes);
    for contigNum2 = 1:numContigs2
        gumbelCurveMu = gumbelCurveMus(contigNum2);
        gumbelCurveBeta = gumbelCurveBetas(contigNum2);
        sValsMat(contigNum2, idxRangeUnflipped) = calculate_p_value(gumbelCurveMu, gumbelCurveBeta, ccValsUnflipped(contigNum2));
        sValsMat(contigNum2, idxRangeFlipped) = calculate_p_value(gumbelCurveMu, gumbelCurveBeta, ccValsFlipped(contigNum2));
    end
end