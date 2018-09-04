function [zeroModelKbpsPerPixel, meanZeroModelFftFreqMags] = prompt_zero_model_info(zeroModelRandSeqsLen_bps, barcodeGenSettings)
    import CBT.Core.gen_unscaled_cbt_barcode;

     %---ZM ---
    %Choose which kind of ZM to be used.
    optRandomSeqBarcodes = 'Random sequence barcodes';
    optBarcodeFiles = 'Choose barcode files';
    optPregenFft = 'Choose a pre-generated FFT';
    zeroModelChoice = questdlg(...
        'Choose zero-model input method', ...
        'Zero-model option', ...
        optRandomSeqBarcodes, ...
        optBarcodeFiles, ...
        optPregenFft, ...
        optRandomSeqBarcodes);

    % ZM preparations
    switch zeroModelChoice
        case optRandomSeqBarcodes
            % Input parameters for random ZM sequencies
            dlg_title_Rand = 'Zero-model random sequences';
            promptRand = {'Number of random sequences:'};
            defaultVals = {num2str(10)};
            num_lines = 1;
            ansRand = inputdlg(...
                promptRand, ...
                dlg_title_Rand, ...
                num_lines, ...
                defaultVals);
            % Input parameters
            zeroModelNumRandSequences = str2double(ansRand{1});

            % Generate sequences
            zeroModelSequences = ceil(4*rand(zeroModelNumRandSequences, zeroModelRandSeqsLen_bps));
            zeroModelSequences = mat2cell(zeroModelSequences, ones(1, zeroModelNumRandSequences), zeroModelRandSeqsLen_bps);


            % Sequence to barcode
            zeroModelBarcodes = cellfun( ...
                @(contigSequence) ...
                    gen_unscaled_cbt_barcode(contigSequence, barcodeGenSettings), ...
                zeroModelSequences, ...
                'UniformOutput', false);
            zeroModelBarcodes = zeroModelBarcodes';
            zeroModelBarcodes = cellfun(@zscore, zeroModelBarcodes, 'UniformOutput', false);

            zeroModelKbpsPerPixel = bpsPerPixel/1000;

            import CBT.RandBarcodeGen.PhaseRandomization.gen_mean_fft_freq_mags;
            meanZeroModelFftFreqMags = gen_mean_fft_freq_mags(zeroModelBarcodes);
        case optBarcodeFiles
            % Choose ZM barcode files

            promptTitle = 'Zero-model consensuses';

            import OptMap.DataImport.prompt_and_read_consensus_outputs;
            [consensusBarcodeNames, consensusBarcodes, ~] = prompt_and_read_consensus_outputs(promptTitle);

            numConsensusBarcodes = length(consensusBarcodes);
            if (numConsensusBarcodes == 0)
                fprintf('A valid consensus file for zero-model generation was not provided\n');
            end

            zeroModelBarcodes = consensusBarcodes;
            zeroModelNames = consensusBarcodeNames;
            import CBT.ExpComparison.UI.standardize_barcodes;
            [zeroModelBarcodes, zeroModelKbpsPerPixel] = standardize_barcodes(zeroModelBarcodes, zeroModelNames);

            import CBT.RandBarcodeGen.PhaseRandomization.gen_mean_fft_freq_mags;
            meanZeroModelFftFreqMags = gen_mean_fft_freq_mags(zeroModelBarcodes);
        case optPregenFft
            import CBT.UI.prompt_pregen_zero_model;
            [aborted, meanZeroModelFftFreqMags, zeroModelKbpsPerPixel] = prompt_pregen_zero_model();
            if aborted
                fprintf('A valid pregenerated zero-model was not provided\n');
            end
        otherwise
            zeroModelKbpsPerPixel = [];
            meanZeroModelFftFreqMags = [];
            fprintf('A zero-model input/generation method not provided\n');
    end
end
