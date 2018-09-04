function [theoryCurves_pxRes_atStretches, theoryCurves_bpRes_prePSF, randomTheorySequences] = get_random_theory_curves_pxRes(lengthOfSequences, numSequences, concNetropsin_molar, concYOYO1_molar,  psfSigmaWidth_bp, meanBpExt_pixels, stretchFactors)
    import Fancy.Utils.cellify_rows;
    import CBT.TheoryComparison.PValue.get_theory_curves_bpRes_prePSF_from_sequences;
    import CBT.TheoryComparison.PValue.convert_theory_curves_to_pxRes;

    fprintf('Generating %d random DNA sequences of length %d...', numSequences, lengthOfSequences);
    randomTheorySequences = cellify_rows(int2nt(randi([1,4], [numSequences, lengthOfSequences])));
    theoryCurves_bpRes_prePSF = get_theory_curves_bpRes_prePSF_from_sequences(randomTheorySequences, concNetropsin_molar, concYOYO1_molar);
    assignin('base','theoryCurves_bpRes_prePSF', theoryCurves_bpRes_prePSF);
    theoryCurves_pxRes_atStretches = convert_theory_curves_to_pxRes(theoryCurves_bpRes_prePSF, psfSigmaWidth_bp, meanBpExt_pixels, stretchFactors);
end