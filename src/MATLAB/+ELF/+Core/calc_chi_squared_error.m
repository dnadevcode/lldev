function [ chiSquaredVal ] = calc_chi_squared_error(y, yfit, stdNoise)
    diffsVect = y(:) - yfit(:);
    chiSquaredVal = sum(diffsVect .^ 2)/(stdNoise .^ 2);
end