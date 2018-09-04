function [outlierScore] = get_outlier_score(values, meanVal, stdVal)
    import CBT.TheoryComparison.ResultAnalysis.Core.get_gumbel_mu_and_beta;
    
    values = values(not(isnan(values)));
    [gumbelCurveMu, gumbelCurveBeta] = get_gumbel_mu_and_beta(meanVal, stdVal);
    outlierScore = 1 - exp(-exp(-(values - gumbelCurveMu)/gumbelCurveBeta)); % outlier score ("p-value" approximation)
end