function thyCurveBitmask = get_theory_bitmask(thyCurve, asIfExperiment, deltaCut, psfSigmaWidth_nm, pixelWidth_nm)
    import CBT.TheoryComparison.get_std_experiment_bitmask;

    if asIfExperiment
        thyCurveBitmask = get_std_experiment_bitmask(length(thyCurve), deltaCut, psfSigmaWidth_nm, pixelWidth_nm);
        if isempty(thyCurveBitmask)
            warning('Empty curve');
        elseif not(any(thyCurveBitmask))
            warning('Edge region takes up entire curve');
        end
    else
        thyCurveBitmask = true(size(thyCurve));
    end
end