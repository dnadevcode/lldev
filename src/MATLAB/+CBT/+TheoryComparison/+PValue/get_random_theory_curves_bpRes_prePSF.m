function [theoryCurves_bpRes_prePSF, randomTheorySequences] = get_random_theory_curves_bpRes_prePSF(lengthOfSequences, numSequences, concNetropsin_molar, concYOYO1_molar)
    import Fancy.Utils.cellify_rows;
    import CBT.TheoryComparison.PValue.get_theory_curves_bpRes_prePSF_from_sequences;

    fprintf('Generating %d random DNA sequences of length %d...', numSequences, lengthOfSequences);
    randomTheorySequences = cellify_rows(int2nt(randi([1,4], [numSequences, lengthOfSequences])));
    theoryCurves_bpRes_prePSF = get_theory_curves_bpRes_prePSF_from_sequences(randomTheorySequences, concNetropsin_molar, concYOYO1_molar);
end