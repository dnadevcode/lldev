function [theoryCurves_bpRes_prePSF] = generate_rand_bpRes_prePSF_from_permutations_of_sequence(numPermutations, baseTheorySequence, concNetropsin_molar, concYOYO1_molar)
    theorySequenceLength = length(baseTheorySequence);
    import CBT.TheoryComparison.PValue.generate_random_reorderings;
    permutations = generate_random_reorderings(theorySequenceLength, numPermutations);
    theorySequencePermutations = cellfun(@(perm) baseTheorySequence(perm), permutations, 'UniformOutput', false);
    
    import CBT.TheoryComparison.PValue.get_theory_curves_bpRes_prePSF_from_sequences;
    theoryCurves_bpRes_prePSF = get_theory_curves_bpRes_prePSF_from_sequences(theorySequencePermutations, concNetropsin_molar, concYOYO1_molar);
end