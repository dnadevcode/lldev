function [] = run_comb_auc_method(tsCA)
    % runs combinatorial auction based contig assignment.

    % initialise consensus import tab
    import CA.CombAuc.UI.launch_comb_auc_ui;
    [lm,tsCA] = launch_comb_auc_ui(tsCA);
    

    
end