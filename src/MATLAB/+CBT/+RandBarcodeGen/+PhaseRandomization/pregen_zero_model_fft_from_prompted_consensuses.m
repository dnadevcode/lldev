function [] = pregen_zero_model_fft_from_prompted_consensuses()
    import OptMap.DataImport.prompt_and_read_consensus_outputs;
    promptTitle = 'Select Zero-model Reference Consensus Files';
    [zeroModelBarcodeNames, zeroModelBarcodes, ~] = prompt_and_read_consensus_outputs(promptTitle);

    import CBT.ExpComparison.UI.standardize_barcodes;
    [zeroModelBarcodes, kbpsPerPixel] = standardize_barcodes(zeroModelBarcodes, zeroModelBarcodeNames);
    if isempty(kbpsPerPixel)
        return;
    end
    meanBpExt_pixels = 1/(kbpsPerPixel*1000);

    import CBT.UI.prompt_should_rescale;
    shouldRescale = prompt_should_rescale();
    if shouldRescale
        zeroModelBarcodes = cellfun(@zscore, zeroModelBarcodes, 'UniformOutput', false);
    end

    fprintf('Generating a zero-model fft...\n');
    import CBT.RandBarcodeGen.PhaseRandomization.gen_mean_fft_freq_mags_alt;
    meanZeroModelFftFreqMags = gen_mean_fft_freq_mags_alt(zeroModelBarcodes);

    import CBT.RandBarcodeGen.PhaseRandomization.export_fft_file;
    export_fft_file(meanZeroModelFftFreqMags, meanBpExt_pixels);

    fprintf('Finished generating ZM fft from consensuses\n')
end