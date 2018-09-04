function comparisonResults = compare_theory_to_theories(theoryStruct, comparableTheories, constantSettingsStruct, cacheResultsSubfolderPath)
    import CBT.TheoryComparison.Core.compare_theory_to_theory;

    numComparableTheories = length(comparableTheories);
    comparisonResults = cell(numComparableTheories, 1);
    for comparableTheoryNum=1:numComparableTheories
        fprintf('   Comparing to theory curve #%d/%d\n', comparableTheoryNum, numComparableTheories);
        comparisonResults{comparableTheoryNum} = compare_theory_to_theory(theoryStruct, comparableTheories{comparableTheoryNum}, constantSettingsStruct, cacheResultsSubfolderPath);
    end
end