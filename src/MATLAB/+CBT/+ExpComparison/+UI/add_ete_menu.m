function [] = add_ete_menu(hMenuParent, tsETE)
    hMenuETE = uimenu( ...
        'Parent', hMenuParent, ...
        'Label', 'ETE');
    

    % Pre-generate FFT for extreme distrubution parameters
    hMenuFFTGenerate = uimenu(hMenuETE, 'Label','Pregenerate FFT Zero Models');
    import CBT.RandBarcodeGen.PhaseRandomization.pregen_zero_model_fft_from_prompted_nt_seqs;
    uimenu(hMenuFFTGenerate,'Label', 'From sequences', 'Callback', @(~, ~) pregen_zero_model_fft_from_prompted_nt_seqs());
    import CBT.RandBarcodeGen.PhaseRandomization.pregen_bp_level_zero_model_fft_from_prompted_nt_seqs;
    uimenu(hMenuFFTGenerate,'Label', 'From sequences (bp level)', 'Callback', @(~, ~) pregen_bp_level_zero_model_fft_from_prompted_nt_seqs());
    import CBT.RandBarcodeGen.PhaseRandomization.pregen_zero_model_fft_from_prompted_consensuses;
    uimenu(hMenuFFTGenerate,'Label', 'From prompted consensus barcodes', 'Callback', @(~, ~) pregen_zero_model_fft_from_prompted_consensuses());

    % Experiment to experiment comparison
    import CBT.ExpComparison.UI.run_consensus_vs_consensus_similarity_analysis;
    uimenu(hMenuETE,'Label', 'Analyze Consensus vs Consensus Similarity', 'Callback', @(~, ~) run_consensus_vs_consensus_similarity_analysis(tsETE));

     % Experiment to experiment comparison with bitmasks
%     import CBT.ExpComparison.UI.run_similarity_analysis;
%     uimenu(hMenuETE,'Label', 'Analyze (bitmasked) Consensus vs Consensus Similarity (beta)', 'Callback', @(~, ~) run_similarity_analysis(tsETE));

 
    import CBT.ExpComparison.Import.load_ete_results;
    uimenu(hMenuETE,'Label', 'Load ETE Results', 'Callback', @(~, ~) load_ete_results(tsETE));

end