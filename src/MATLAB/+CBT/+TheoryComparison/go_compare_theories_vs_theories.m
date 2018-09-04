function [] = go_compare_theories_vs_theories(ts, theoriesFromDisplayName, theoryNamesA, theoryNamesB, constSettings, cacheResultsSubfolderPath)
    numTheoriesA = length(theoryNamesA);
    theoriesA = cell(numTheoriesA, 1);
    for theoryNumA=1:numTheoriesA
        theoryDisplayName = theoryNamesA{theoryNumA};
        theoryDisplayNameStruct = theoriesFromDisplayName(theoryDisplayName);
        theoriesA{theoryNumA} = theoryDisplayNameStruct;
    end
    import CBT.TheoryComparison.Core.get_length_ordering_for_theories;
    [~, orderedTheoryIndicesA] = get_length_ordering_for_theories(theoriesA, constSettings.nmPerBp);
    theoryNamesA = theoryNamesA(orderedTheoryIndicesA);
    theoriesA = theoriesA(orderedTheoryIndicesA);
    assignin('base', 'theoryNamesA', theoryNamesA);
    assignin('base', 'theoryStructsA', theoriesA);

    numTheoriesB = length(theoryNamesB);
    theoriesB = cell(numTheoriesB, 1);
    for theoryNumB=1:numTheoriesB
        theoryDisplayName = theoryNamesB{theoryNumB};
        theoryDisplayNameStruct = theoriesFromDisplayName(theoryDisplayName);
        theoriesB{theoryNumB} = theoryDisplayNameStruct;
    end
    [~, orderedTheoryIndicesB] = get_length_ordering_for_theories(theoriesB, constSettings.nmPerBp);
    theoryNamesB = theoryNamesB(orderedTheoryIndicesB);
    theoriesB = theoriesB(orderedTheoryIndicesB);
    assignin('base', 'theoryNamesB', theoryNamesB);
    assignin('base', 'theoryStructsB', theoriesB);

    import CBT.TheoryComparison.Core.compare_theories_to_theories;
    comparisonResults = compare_theories_to_theories(theoriesA, theoriesB, constSettings, cacheResultsSubfolderPath);
    assignin('base', 'theoryVsTheoryResults', comparisonResults);

    comparisonResultsByField = struct;
    scalarNumberFields = {'bestCC', 'meanCC', 'stdCC', 'bestStretchFactor', 'numStretchFactors'};
    import CBT.TheoryComparison.Core.extract_scalarMat;
    for theoryNumA=1:length(scalarNumberFields)
        fieldName = scalarNumberFields{theoryNumA};
        comparisonResultsByField.(fieldName) = extract_scalarMat(comparisonResults, fieldName, NaN);
    end
    assignin('base', 'theoryVsTheoryResultsByField', comparisonResultsByField);
    
    import CBT.TheoryComparison.UI.plot_heat_maps;
    plot_heat_maps(ts, comparisonResultsByField);
    fprintf('Theory vs. Theory Calculations Complete\n');
    fprintf('Check workspace variables for results!\n');
end