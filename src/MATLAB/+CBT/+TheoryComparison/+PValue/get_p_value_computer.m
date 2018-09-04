function [pValueComputer, rI, cHatMean, mu, sigma, I] = get_p_value_computer(cHatMean, mu, sigma, I)
    % See "Robust method for determining the effective sample size from
    % correlated data sets" (Documentation\writeup_Neff.pdf)

    import CBT.TheoryComparison.PValue.find_effective_correlation_length;

    rI = find_effective_correlation_length(cHatMean, mu, sigma, I);
    sqrtDoubleVariance = sqrt(2*sigma.^2);
    function [pValue, effectiveCorrelationLength] = fn_p_value_computer(cHatActual)
        effectiveCorrelationLength = rI;
        pValue = 1 - ((1 + erf((cHatActual - mu)/sqrtDoubleVariance))/2)^rI;
    end
    pValueComputer = @fn_p_value_computer;
end