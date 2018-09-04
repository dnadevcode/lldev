function [barcodes, ntSeqs, fastaHeaders, fastaFilepaths] = gen_unscaled_barcodes(fastaFilepaths, barcodeGenSettings)
    if nargin < 1
        import NtSeq.Import.UI.try_prompt_nt_seq_filepaths;
        [~, fastaFilepaths] = try_prompt_nt_seq_filepaths('Select contig fasta files', true, false);
    end

    if nargin < 2
        import CBT.get_default_barcode_gen_settings;
        defaultBarcodeGenSettings = get_default_barcode_gen_settings();
        barcodeGenSettings = defaultBarcodeGenSettings;
    end

    import NtSeq.Import.import_fasta_nt_seqs;
    [ntSeqs, fastaHeaders] = import_fasta_nt_seqs(fastaFilepaths);

    import CBT.Core.gen_unscaled_cbt_barcode;
    barcodes = cellfun( ...
        @(ntSequence) ...
            gen_unscaled_cbt_barcode(ntSequence, barcodeGenSettings), ...
        ntSeqs, ...
        'UniformOutput', false);
end