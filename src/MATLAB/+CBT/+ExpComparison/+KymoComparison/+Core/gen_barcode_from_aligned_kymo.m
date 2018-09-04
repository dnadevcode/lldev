function [kymoBarcode] = gen_barcode_from_aligned_kymo(alignedKymoImg)
    import OldDBM.Kymo.Core.find_signal_region_with_otsu;

    kymoTimeAvg = nanmean(alignedKymoImg, 1);
    [fgStartIdx, fgEndIdx] = find_signal_region_with_otsu(kymoTimeAvg);
    kymoBarcode = zscore(kymoTimeAvg(fgStartIdx:fgEndIdx));
end