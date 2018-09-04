function [theoryCurveUnscaled_pxRes] = gen_unscaled_cbt_barcode(ntSeq, barcodeGenSettings)
    if nargin < 2
        barcodeGenSettings = [];
    end
    import CBT.Core.gen_unscaled_cbt_barcodes;
    [theoryCurvesUnscaled_pxRes] = gen_unscaled_cbt_barcodes({ntSeq}, barcodeGenSettings);
    theoryCurveUnscaled_pxRes = theoryCurvesUnscaled_pxRes{1};
end