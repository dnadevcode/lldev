function theoryLengths = get_theory_lengths(theoryStructs, meanBpExt_nm)
    import CBT.TheoryComparison.Core.get_theory_length;

    numTheories = length(theoryStructs);
    theoryLengths = zeros(numTheories, 1);
    for theoryNum = 1:numTheories
        theoryLengths(theoryNum) = get_theory_length(theoryStructs{theoryNum}, meanBpExt_nm);
    end
end