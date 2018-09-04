function [pValue, pValueComputer, effectiveCorrelationLength, cHatMean, mu, sigma, I] = compute_p_value(baselineTheoryCurves_pxRes_bySF, otherCurve_pxRes, otherCurveBitmask, bestCC_actual)
    import CBT.TheoryComparison.PValue.get_baseline;
    import CBT.TheoryComparison.PValue.get_p_value_computer;

    [cHatMean, mu, sigma, I] = get_baseline(baselineTheoryCurves_pxRes_bySF, otherCurve_pxRes, otherCurveBitmask);
    pValueComputer = get_p_value_computer(cHatMean, mu, sigma, I);
    [pValue, effectiveCorrelationLength] = pValueComputer(bestCC_actual);
end