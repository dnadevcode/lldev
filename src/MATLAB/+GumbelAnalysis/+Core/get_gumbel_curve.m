function [gumbelCurveX, gumbelCurveY] = get_gumbel_curve(gumbelCurveMu, gumbelCurveBeta)
    gumbelCurveX = 0:0.001:1;
    x = (gumbelCurveX - gumbelCurveMu) / gumbelCurveBeta;
    gumbelCurveY = exp(-(x + exp(-x)));
end