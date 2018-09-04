function [pValue] = calculate_p_value(gumbelCurveMu, gumbelCurveBeta, bestCC)
    % Using Gumbel distribution as a null model in order to calculate
    % p-values

    pValue = 1 - exp(-exp(-(bestCC - gumbelCurveMu) / gumbelCurveBeta));
end