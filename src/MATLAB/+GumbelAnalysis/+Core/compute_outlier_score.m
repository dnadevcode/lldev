function [outlierScores] = compute_outlier_score(values, gumbelCurveMu, gumbelCurveBeta)
    outlierScores = 1 - exp(-exp(-(values - gumbelCurveMu)/gumbelCurveBeta));
end