function [pValue, pValueComputer, effectiveCorrelationLength, cHatMean, mu, sigma, I] = compute_p_value_for_TvE(baselineTheoryCurves_pxRes, expCurveStruct, constantSettingsStruct, bestCC_actual)
    import CBT.TheoryComparison.PValue.get_pxRes_other_curve_and_bitmask_from_struct;
    import CBT.TheoryComparison.PValue.compute_p_value;

    [experimentCurve_pxRes, experimentCurveBitmask] = get_pxRes_other_curve_and_bitmask_from_struct(expCurveStruct, true, constantSettingsStruct);
    if isempty(experimentCurveBitmask)
        warning('Empty curve');
    elseif not(any(experimentCurveBitmask))
        warning('No curve values were included');
    end
        
    [pValue, pValueComputer, effectiveCorrelationLength, cHatMean, mu, sigma, I] = compute_p_value(baselineTheoryCurves_pxRes, experimentCurve_pxRes, experimentCurveBitmask, bestCC_actual);
end