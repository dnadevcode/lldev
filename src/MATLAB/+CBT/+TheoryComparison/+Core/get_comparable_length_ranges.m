function [minComparableOrderedIndices, maxComparableOrderedIndices, minComparableLengths, maxComparableLengths] = get_comparable_length_ranges(orderedTheoryLengths, orderedComparisonLengths, maxPairLengthDiffRelative, maxPairLengthDiffAbsolute)
    minComparableLengths = max((orderedTheoryLengths*(1-maxPairLengthDiffRelative)), orderedTheoryLengths - maxPairLengthDiffAbsolute);
    maxComparableLengths = min((orderedTheoryLengths/(1-maxPairLengthDiffRelative)), orderedTheoryLengths + maxPairLengthDiffAbsolute);
    numTheories = length(orderedTheoryLengths);
    minComparableOrderedIndices = zeros(numTheories, 1);
    maxComparableOrderedIndices = zeros(numTheories, 1);
    for theoryNum=1:numTheories
        bigEnough = orderedComparisonLengths >= minComparableLengths(theoryNum);
        smallEnough = orderedComparisonLengths <= maxComparableLengths(theoryNum);

        minComparableOrderedIndices(theoryNum) = min([find(bigEnough, 1, 'first'), Inf]);
        maxComparableOrderedIndices(theoryNum) = max([find(smallEnough, 1, 'last'), -Inf]);
    end
end