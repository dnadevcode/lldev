function [gumbelCurveMu, gumbelCurveBeta] = get_gumbel_mu_and_beta(meanVal, stdVal)
    gumbelCurveBeta = stdVal*(sqrt(6)/ pi);
    % Note: vpa(eulergamma()) gives the Euler–Mascheroni constant in
    %   floating point
    gumbelCurveMu = meanVal - (gumbelCurveBeta * double(eulergamma()));
end