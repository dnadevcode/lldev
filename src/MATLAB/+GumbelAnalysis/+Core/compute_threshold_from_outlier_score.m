function [valueThresholds] = compute_threshold_from_outlier_score(alphas, gumbelCurveMu, gumbelCurveBeta)
    valueThresholds = gumbelCurveBeta * (-log(-log(1 - alphas))) + gumbelCurveMu;
end