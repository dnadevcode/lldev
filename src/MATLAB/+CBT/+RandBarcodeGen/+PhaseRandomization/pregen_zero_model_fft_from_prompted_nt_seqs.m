 function [] = pregen_zero_model_fft_from_prompted_nt_seqs()

    % Select sequence files
    import NtSeq.Import.UI.try_prompt_nt_seq_filepaths;
    [aborted, fastaFilepaths] = try_prompt_nt_seq_filepaths([], [], false);

    % Load sequencies
    import NtSeq.Import.import_fasta_nt_seqs;
    ntSeqs = import_fasta_nt_seqs(fastaFilepaths);

    if aborted || isempty(ntSeqs)
        fprintf('No sequences were provided\n');
        return;
    end
    numSeqs = length(ntSeqs);
    if numSeqs == 1
        fprintf('Only one sequence was provided\n')
    end

    import CBT.ExpComparison.UI.get_zero_model_seq2barcode_gen_settings;
    barcodeGenSettings = get_zero_model_seq2barcode_gen_settings();

    % Sequence to barcodes
    import CBT.Core.gen_unscaled_cbt_barcode;
    zeroModelBarcodes = cellfun(@(ntSeq) gen_unscaled_cbt_barcode(ntSeq, barcodeGenSettings), ntSeqs(:), 'UniformOutput', false);

    meanBpExt_pixels = barcodeGenSettings.meanBpExt_nm/barcodeGenSettings.pixelWidth_nm;


    % Reisner-rescale each individual barcode
    %  to have a mean of 0 and variance of 1
    shouldRescale = true;
    if shouldRescale
        zeroModelBarcodes = cellfun(@zscore, zeroModelBarcodes, 'UniformOutput', false);
    end

    fprintf('Generating a zero-model fft...\n');
    import CBT.RandBarcodeGen.PhaseRandomization.gen_mean_fft_freq_mags_alt;
    meanZeroModelFftFreqMags = gen_mean_fft_freq_mags_alt(zeroModelBarcodes);

    import CBT.RandBarcodeGen.PhaseRandomization.export_fft_file;
    export_fft_file(meanZeroModelFftFreqMags, meanBpExt_pixels);

    fprintf('Finished generating ZM fft from sequences\n')
end