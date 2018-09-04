function [pValueUpperError, pValueLowerError, pValueUpperBounds, pValueLowerBounds] = p_value_error_info(values, gumbelCurveMu, gumbelCurveBeta)
    numValues = sum(~isnan(values));
    stdValue = nanstd(values);
    standardError = stdValue./sqrt(numValues);
    pValueUpperBounds = 1 - exp(-exp(-(values - gumbelCurveMu - standardError)./gumbelCurveBeta));
    pValueLowerBounds = 1 - exp(-exp(-(values - gumbelCurveMu + standardError)./gumbelCurveBeta));
    pValueUpperError = pValueUpperBounds - pValues;
    pValueLowerError = pValues - pValueLowerBounds;
end