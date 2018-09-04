function [rescaleMean, rescaleStd] = acquire_rescale_factors()

    import NtSeq.Import.UI.try_prompt_nt_seq_filepaths;
    [~, fastaFilepaths] = try_prompt_nt_seq_filepaths('Select fasta files for barcode rescaling', true, false);
    
    import CA.Old.Core.gen_unscaled_barcodes;
    unscaledBarcodes = gen_unscaled_barcodes(fastaFilepaths);
    aggregatedUnscaledBarcodes = horzcat(unscaledBarcodes{:});
    rescaleMean = nanmean(aggregatedUnscaledBarcodes);
    rescaleStd = nanstd(aggregatedUnscaledBarcodes);
end