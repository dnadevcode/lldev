function [pValue, pValueComputer, effectiveCorrelationLength, cHatMean, mu, sigma, I] = compute_p_value_for_TvE_from_results(experimentStruct, resultsStruct, settingsParams, numSequences)
    if nargin < 4
        numSequences = 100;
    end

    import CBT.TheoryComparison.PValue.get_random_theory_curves_pxRes;
    import CBT.TheoryComparison.PValue.compute_p_value_for_TvE;

    lengthOfSequences = resultsStruct.structA.sequenceLength;
    if length(resultsStruct.stretchFactors) > 1
        warning('Cheating! Since multiple stretch factors were used, using the stretch factor that produced the bestCC is probably cheating to some extent!');
    end
    stretchFactors = resultsStruct.bestStretchFactor; % Tobias said to do this because the math for p-values for a sum of gumbels is way too complicated, but this is kind of cheating if there are other stretch factors that were tested in reality!
                    %resultsStruct.stretchFactors;
    concNetropsin_molar = settingsParams.NETROPSINconc;
    concYOYO1_molar = settingsParams.YOYO1conc;
    psfSigmaWidth_bp = settingsParams.psfWidth_bp;
    meanBpExt_pixels = settingsParams.pixelsPerBp;
    bestCC_actual = resultsStruct.bestCC;

    baselineTheoryCurves_pxRes_atStretches = get_random_theory_curves_pxRes(lengthOfSequences, numSequences, concNetropsin_molar, concYOYO1_molar,  psfSigmaWidth_bp, meanBpExt_pixels, stretchFactors);
    [pValue, pValueComputer, effectiveCorrelationLength, cHatMean, mu, sigma, I] = compute_p_value_for_TvE(baselineTheoryCurves_pxRes_atStretches, experimentStruct, settingsParams, bestCC_actual);
end