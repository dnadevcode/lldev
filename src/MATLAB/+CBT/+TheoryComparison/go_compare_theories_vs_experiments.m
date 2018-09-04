function [] = go_compare_theories_vs_experiments(ts, theoryStructs, experimentStructs, constSettings, cacheResultsSubfolderPath)
    import CBT.TheoryComparison.Core.compare_all_theories_to_all_experiments;
    comparisonResults = compare_all_theories_to_all_experiments(theoryStructs, experimentStructs, constSettings, cacheResultsSubfolderPath);
    assignin('base', 'theoryVsExperimentResults', comparisonResults);

    comparisonResultsByField = struct;
    fieldNamesForScalarNumbers = {'bestCC', 'meanCC', 'stdCC', 'bestStretchFactor', 'numStretchFactors'};
    numScalarNumberFields = length(fieldNamesForScalarNumbers);
    import CBT.TheoryComparison.Core.extract_scalarMat;
    for scalarNumberFieldNum=1:numScalarNumberFields
        fieldNameForScalarNumbers = fieldNamesForScalarNumbers{scalarNumberFieldNum};
        comparisonResultsByField.(fieldNameForScalarNumbers) = extract_scalarMat(comparisonResults, fieldNameForScalarNumbers, NaN);
    end
    assignin('base', 'theoryVsExperimentResultsByField', comparisonResultsByField);
    
    import CBT.TheoryComparison.UI.plot_heat_maps;
    plot_heat_maps(ts, comparisonResultsByField);
    fprintf('Theory vs. Theory Calculations Complete\n');
    fprintf('Check workspace variables for results!\n');
end