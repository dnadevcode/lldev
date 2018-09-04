function comparisonResults = compare_theories_to_theories(theoriesA, theoriesB, constantSettingsStruct, cacheResultsSubfolderPath)
    import Fancy.Utils.extract_fields;
    [maxPairLengthDiffRelative, maxPairLengthDiffAbsolute_nm, meanBpExt_nm] = extract_fields(constantSettingsStruct,...
        {'maxPairLengthDiffRelative', 'maxPairLengthDiffAbsolute_nm', 'nmPerBp'});
    
    import CBT.TheoryComparison.Core.get_length_ordering_for_theories;
    [orderedTheoryLengthsA, orderedTheoryIndicesA] = get_length_ordering_for_theories(theoriesA, meanBpExt_nm);
    [orderedTheoryLengthsB, orderedTheoryIndicesB] = get_length_ordering_for_theories(theoriesB, meanBpExt_nm);
    
    import CBT.TheoryComparison.Core.get_comparable_length_ranges;
    [minComparableOrderedIndices, maxComparableOrderedIndices, ~, ~] = get_comparable_length_ranges(orderedTheoryLengthsA, orderedTheoryLengthsB, maxPairLengthDiffRelative, maxPairLengthDiffAbsolute_nm);
    numTheoriesA = length(theoriesA);
    numTheoriesB = length(theoriesB);
    comparisonResults = cell(numTheoriesA, numTheoriesB);
    comparisonsToBeMade = max(0, maxComparableOrderedIndices + 1 - minComparableOrderedIndices);
    assignin('base', 'comparisonsToBeMade', comparisonsToBeMade);
    maxComparisonSize = zeros(numTheoriesA, 1);
    for theoryNumA=1:numTheoriesA
        maxComparisonSize(theoryNumA) = orderedTheoryLengthsB(maxComparableOrderedIndices(theoryNumA));
    end
    assignin('base', 'maxComparisonSize', maxComparisonSize);

    times = zeros(numTheoriesA, 1);

    import CBT.TheoryComparison.Core.compare_theory_to_theories;
    for theoryNumA=1:numTheoriesA
        trueTheoryIndexA = orderedTheoryIndicesA(theoryNumA);
        indices = minComparableOrderedIndices(theoryNumA):maxComparableOrderedIndices(theoryNumA);
        if isempty(indices)
            % fprintf('No Comparisons for theory #%d/%d\n', theoryNumA, numTheoriesA);
        else
            fprintf('Comparisons for theory #%d/%d\n', theoryNumA, numTheoriesA);
        end
        trueComparisonTheoryIndicesB = orderedTheoryIndicesB(indices);

        tStart = tic;
        comparisonResults(trueTheoryIndexA, trueComparisonTheoryIndicesB) = compare_theory_to_theories(theoriesA{trueTheoryIndexA}, theoriesB(trueComparisonTheoryIndicesB), constantSettingsStruct, cacheResultsSubfolderPath);
        times(theoryNumA) = toc(tStart);
    end
    assignin('base', 'times', times);
end