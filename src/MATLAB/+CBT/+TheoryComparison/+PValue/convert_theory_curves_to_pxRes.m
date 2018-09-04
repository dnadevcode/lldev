function theoryCurves_pxRes_atStretches = convert_theory_curves_to_pxRes(theoryCurves_bpRes_prePSF, psfSigmaWidth_bp, meanBpExt_pixels, stretchFactors)
    if (nargin < 4) || isempty(stretchFactors)
        stretchFactors = 1;
    end

    import CBT.Core.apply_stretching;
    import Microscopy.Simulate.Core.apply_point_spread_function;
    import CBT.Core.convert_bpRes_to_pxRes;


    numStretchFactors = length(stretchFactors);
    theoryCurves_pxRes_atStretches = cell(numStretchFactors, 1);
    for stretchFactorNum=1:numStretchFactors
        stretchFactor = stretchFactors(stretchFactorNum);

        % Stretch/compress based on stretch factor
        if stretchFactor ~= 1
            theoryCurves_bpRes_prePSF_sf = cellfun(@(curve) apply_stretching(curve, stretchFactor), theoryCurves_bpRes_prePSF, 'UniformOutput', false);
        end

        % Smooth in basepair resolution by convolving curve with PSF
        theoryCurves_bpRes_sf = cellfun(@(thyCurve_bpRes_prePSF) apply_point_spread_function(thyCurve_bpRes_prePSF, psfSigmaWidth_bp), theoryCurves_bpRes_prePSF_sf, 'UniformOutput', false);

        % Convert to pixel resolution (and also reisner-rescale)
        theoryCurves_pxRes_atStretches{stretchFactorNum} =  cellfun(@(curve) zscore(convert_bpRes_to_pxRes(curve, meanBpExt_pixels)), theoryCurves_bpRes_sf, 'UniformOutput', false);
    end
end