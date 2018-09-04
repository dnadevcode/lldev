function [theoryCurves_pxRes] = generate_rand_pxRes_from_permutations_of_pxRes_curve(numPermutations, baseCurve_pxRes)
    import CBT.TheoryComparison.PValue.generate_random_reorderings;

    theoryCurveLength = length(baseCurve_pxRes);
    permutations = generate_random_reorderings(theoryCurveLength, numPermutations);
    theoryCurves_pxRes = cellfun(@(perm) baseCurve_pxRes(perm), permutations, 'UniformOutput', false);
end