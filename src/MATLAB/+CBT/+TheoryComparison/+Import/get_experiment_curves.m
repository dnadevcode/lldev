function [aborted, experimentCurveNames, experimentCurveStructs] = get_experiment_curves()
    experimentCurveStructs = cell(0, 1);
    experimentCurveNames = cell(0, 1);
    choice = menu('What type of experiment curves would you like to import?','Kymo-average barcodes from a DBM session file','Consensus barcodes from a consensus results file');
    if choice == 1
        import CBT.TheoryComparison.Import.get_experiment_curves_from_DBM_session;
        [aborted, experimentCurveNames, experimentCurveStructs] = get_experiment_curves_from_DBM_session();
    elseif choice == 2
        import CBT.TheoryComparison.Import.get_consensus_curves_from_results;
        [aborted, experimentCurveNames, experimentCurveStructs] = get_consensus_curves_from_results();
    else
        aborted = true;
    end
end