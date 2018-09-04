function [orderedTheoryLengths, orderedTheoryIndices] = get_length_ordering_for_theories(theoryStructs, meanBpExt_nm)
    import CBT.TheoryComparison.Core.get_theory_lengths;

    theoryLengths = get_theory_lengths(theoryStructs, meanBpExt_nm);
    [orderedTheoryLengths, orderedTheoryIndices] = sort(theoryLengths);
end