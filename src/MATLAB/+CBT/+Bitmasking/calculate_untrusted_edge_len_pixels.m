function [untrustedEdgeLength_pixels] = calculate_untrusted_edge_len_pixels(barcodeGenSettings)
    if (nargin < 1) || isempty(barcodeGenSettings)
        import CBT.get_default_barcode_gen_settings;
        defaultBarcodeGenSettings = get_default_barcode_gen_settings();
        barcodeGenSettings = defaultBarcodeGenSettings;
    end
    stretchFactor = barcodeGenSettings.stretchFactor;
    deltaCut = barcodeGenSettings.deltaCut;
    psfSigmaWidth_nm = barcodeGenSettings.psfSigmaWidth_nm;
    pixelWidth_nm = barcodeGenSettings.pixelWidth_nm;
    untrustedEdgeLength_pixels = ceil(stretchFactor * deltaCut * psfSigmaWidth_nm / pixelWidth_nm);
end