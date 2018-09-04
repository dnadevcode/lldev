function [comparisonResults] = compare_all_theories_to_all_experiments(theories, experiments, constantSettingsStruct, cacheResultsSubfolderPath)
    import Fancy.Utils.extract_fields;
    [maxPairLengthDiffRelative, maxPairLengthDiffAbsolute_nm, meanBpExt_nm, pixelWidth_nm] = extract_fields(constantSettingsStruct,...
        {'maxPairLengthDiffRelative', 'maxPairLengthDiffAbsolute_nm', 'nmPerBp', 'nmPerPixel'});
    
    import CBT.TheoryComparison.Core.get_length_ordering_for_theories;
    [orderedTheoryLengths, orderedTheoryIndices] = get_length_ordering_for_theories(theories, meanBpExt_nm);
    
    import CBT.TheoryComparison.Core.get_length_ordering_for_experiments;
    [orderedExperimentLengths, orderedExperimentIndices] = get_length_ordering_for_experiments(experiments, pixelWidth_nm);
    
    import CBT.TheoryComparison.Core.get_comparable_length_ranges;
    [minComparableOrderedIndices, maxComparableOrderedIndices, ~, ~] = get_comparable_length_ranges(orderedTheoryLengths, orderedExperimentLengths, maxPairLengthDiffRelative, maxPairLengthDiffAbsolute_nm);
    numTheories = length(theories);
    numExperiments = length(experiments);
    comparisonResults = cell(numTheories, numExperiments);
    comparisonsToBeMade = max(0, maxComparableOrderedIndices + 1 - minComparableOrderedIndices);
    assignin('base', 'comparisonsToBeMade', comparisonsToBeMade);
    maxComparisonSize = zeros(numTheories, 1);
    for theoryNum = 1:numTheories
        maxComparableIndex = maxComparableOrderedIndices(theoryNum);
        if maxComparableIndex >= 1
            maxComparisonSize(theoryNum) = orderedExperimentLengths(maxComparableIndex);
        end
    end
    assignin('base', 'maxComparisonSize', maxComparisonSize);

    import CBT.TheoryComparison.Core.compare_theory_to_experiments;
    for theoryNum = 1:numTheories
        trueTheoryIndex = orderedTheoryIndices(theoryNum);
        indices = minComparableOrderedIndices(theoryNum):maxComparableOrderedIndices(theoryNum);
        if isempty(indices)
            % fprintf('No comparisons for theory #%d/%d\n', theoryNum, numTheories);
        else
            fprintf('Comparisons for theory #%d/%d\n', theoryNum, numTheories);
        end
        trueComparisonExperimentIndices = orderedExperimentIndices(indices);
        comparisonResults(trueTheoryIndex, trueComparisonExperimentIndices) = compare_theory_to_experiments(theories{trueTheoryIndex}, experiments(trueComparisonExperimentIndices), constantSettingsStruct, cacheResultsSubfolderPath);
    end
end