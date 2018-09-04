function [theoryCurves_pxRes] = generate_rand_pxRes_from_permutations_of_sequence(numPermutations, baseTheorySequence, concNetropsin_molar, concYOYO1_molar, psfSigmaWidth_bp, meanBpExt_pixels, stretchFactor)
    import CBT.TheoryComparison.PValue.generate_rand_bpRes_prePSF_from_permutations_of_sequence;
    import CBT.TheoryComparison.PValue.convert_theory_curves_to_pxRes;

    theoryCurves_bpRes_prePSF = generate_rand_bpRes_prePSF_from_permutations_of_sequence(numPermutations, baseTheorySequence, concNetropsin_molar, concYOYO1_molar);
    theoryCurves_pxRes = convert_theory_curves_to_pxRes(theoryCurves_bpRes_prePSF, psfSigmaWidth_bp, meanBpExt_pixels, stretchFactor);
end