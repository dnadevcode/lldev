function [] = add_hca_menu(hMenuParent, tsHCA)
    hMenuETE = uimenu( ...
        'Parent', hMenuParent, ...
        'Label', 'HCA');
    
    % Experiment to experiment comparison
    import CBT.Hcc.run_fragment_vs_theory_similarity_analysis;
    uimenu(hMenuETE,'Label', 'Analyze Fragment vs. Theory Similarity', 'Callback', @(~, ~) run_consensus_vs_consensus_similarity_analysis(tsHCA));

 
    import CBT.ExpComparison.Import.load_ete_results;
    uimenu(hMenuETE,'Label', 'Load ETE Results', 'Callback', @(~, ~) load_ete_results(tsHCA));

end