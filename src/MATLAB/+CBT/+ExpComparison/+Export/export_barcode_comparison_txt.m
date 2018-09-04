function [] = export_barcode_comparison_txt(...
        barcodeNameA, ...
        barcodeNameB, ...
        sameLengthTF, ...
        stretchFactorForAGivenB, ...
        kbpsPerPixel, ...
        pValAB, ...
        ccAB, ...
        longerBarcodeShifted, ...
        barcodeShiftedA, ...
        barcodeShiftedB ...
        )
    barcodeStretchPercentageA = 100 * (stretchFactorForAGivenB - 1.0);
    if sameLengthTF
        sameLengthTFStr = 'True';
    else
        sameLengthTFStr = 'False';
    end
    timestamp = datestr(clock(),'yyyy-mm-dd HH:MM:SS');


    %---Create the file---
    import CBT.ExpComparison.Export.Helpers.prompt_barcode_comparison_output_txt_filepath;
    [~, outputFilepath] = prompt_barcode_comparison_output_txt_filepath();
    if isempty(outputFilepath)
        return;
    end
    fid = fopen(outputFilepath, 'w');
    fprintf(fid, '#Date: %s\n', timestamp);
    fprintf(fid, '#Name of barcode 1: %s\n', barcodeNameA);
    fprintf(fid, '#Name of barcode 2: %s\n', barcodeNameB);
    fprintf(fid, '#Stretched to same length: %s\n', sameLengthTFStr);
    fprintf(fid, '#Barcode 1 stretched for matching: %.0f%%\n', barcodeStretchPercentageA);
    fprintf(fid, '#Kbp per pixel: %s\n', num2str(kbpsPerPixel));
    fprintf(fid, '#P-value: %g\n', pValAB);
    fprintf(fid, '#Cross-correlation: %g\n', ccAB);
    fprintf(fid, '#\n');

    % Write first row (containing barcode names)
    fprintf(fid, '#Intensity 1\t\tIntensity 2\t\t\n');

    % Write the rest
    maxPixelIdx = length(longerBarcodeShifted);
    for pixelIdx = 1:maxPixelIdx
        fprintf(fid, '%5.4f\t\t\t\t%g\n', barcodeShiftedA(pixelIdx), barcodeShiftedB(pixelIdx));
    end
    fclose(fid);
end