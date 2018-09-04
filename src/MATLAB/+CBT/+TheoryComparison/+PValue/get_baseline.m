function [cHatMean, mu, sigma, I] = get_baseline(baselineTheoryCurves_pxRes_bySF, otherCurve_pxRes, otherCurveBitmask)
    import SignalRegistration.XcorrAlign.get_no_extra_cropping_lin_circ_xcorrs;

    numStretchFactors = length(baselineTheoryCurves_pxRes_bySF);
    bestCCs = NaN(numStretchFactors,1);
    for stretchFactorNum=1:numStretchFactors
        theoryCurves_pxRes = baselineTheoryCurves_pxRes_bySF{stretchFactorNum};
        numTheoryCurves = length(theoryCurves_pxRes);
        ccs = cell(numTheoryCurves, 1);
        for theoryCurveNum = 1:numTheoryCurves
            theoryCurve_pxRes = theoryCurves_pxRes{theoryCurveNum};

            [xcorrs, ~, ~] = get_no_extra_cropping_lin_circ_xcorrs(otherCurve_pxRes, theoryCurve_pxRes, otherCurveBitmask, true(size(theoryCurve_pxRes)));
            xcorrs = xcorrs(~isnan(xcorrs));
            xcorrs = xcorrs(:);
            if theoryCurveNum == 1
                bestCCs(stretchFactorNum) = max(xcorrs);
            else
                bestCCs(stretchFactorNum) = max(bestCCs(stretchFactorNum), max(xcorrs));
            end
            ccs{theoryCurveNum} = xcorrs';
        end
    end
    cHatMean = mean(bestCCs);
    ccs = [ccs{:}];
    I = length(ccs);
    mu = mean(ccs(:));
    sigma = std(ccs(:));
end