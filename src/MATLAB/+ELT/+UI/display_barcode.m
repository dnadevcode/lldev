function [] = display_barcode(hAxisBarcodeImg, predictedCurveAfterPsf)
    set(hAxisBarcodeImg, 'YTick', []);
    axes(hAxisBarcodeImg);
    imagesc(predictedCurveAfterPsf);
    colormap(hAxisBarcodeImg, gray);
    xlabel(hAxisBarcodeImg, 'Position (bp)');
end