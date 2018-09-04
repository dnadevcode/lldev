function comparisonResults = compare_theory_to_experiments(theoryStruct, comparableExperiments, constantSettingsStruct, cacheResultsSubfolderPath)
    import CBT.TheoryComparison.Core.compare_theory_to_experiment;

    numComparableExperiments = length(comparableExperiments);
    comparisonResults = cell(numComparableExperiments, 1);
    for comparableExperimentNum=1:numComparableExperiments
        fprintf('   Comparing to experiment curve #%d/%d\n', comparableExperimentNum, numComparableExperiments);
        comparisonResults{comparableExperimentNum} = compare_theory_to_experiment(theoryStruct, comparableExperiments{comparableExperimentNum}, constantSettingsStruct, cacheResultsSubfolderPath);
    end
end