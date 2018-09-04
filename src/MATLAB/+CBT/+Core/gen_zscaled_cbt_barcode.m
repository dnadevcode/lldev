function [theoryCurveZscaled_pxRes] = gen_zscaled_cbt_barcode(ntSeq, barcodeGenSettings)
    if nargin < 2
        barcodeGenSettings = [];
    end
    ntSeqs = {ntSeq};
    import CBT.Core.gen_zscaled_cbt_barcodes;
    theoryCurvesZscaled_pxRes = gen_zscaled_cbt_barcodes(ntSeqs, barcodeGenSettings);
    theoryCurveZscaled_pxRes = theoryCurvesZscaled_pxRes{1};
end