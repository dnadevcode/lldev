function [theoryCurvesZscaled_pxRes] = gen_zscaled_cbt_barcodes(ntSeqs, barcodeGenSettings)
    if nargin < 2
        barcodeGenSettings = [];
    end
    import CBT.Core.gen_unscaled_cbt_barcodes;
    theoryCurvesUnscaled_pxRes = gen_unscaled_cbt_barcodes(ntSeqs, barcodeGenSettings);
    theoryCurvesZscaled_pxRes = cellfun(...
        @zscore, ...
        theoryCurvesUnscaled_pxRes, ...
        'UniformOutput', false);
end