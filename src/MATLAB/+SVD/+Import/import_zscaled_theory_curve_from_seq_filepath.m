function [theoryCurve] = import_zscaled_theory_curve_from_seq_filepath(seqFilepath)
    import NtSeq.Import.try_import_fasta_nt_seq;
    [~, ntSeq] = try_import_fasta_nt_seq(seqFilepath);

    import CBT.get_default_barcode_gen_settings;
    defaultBarcodeGenSettings = get_default_barcode_gen_settings();
    barcodeGenSettings = defaultBarcodeGenSettings;

    import CBT.Core.gen_zscaled_cbt_barcode;
    theoryCurve = gen_zscaled_cbt_barcode(ntSeq, barcodeGenSettings);
end