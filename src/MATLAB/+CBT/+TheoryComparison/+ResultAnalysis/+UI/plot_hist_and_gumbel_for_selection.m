function [] = plot_hist_and_gumbel_for_selection(tsHistAndGumbel, theoryNames, bestCCs, gumbelCurveMusByIteration, gumbelCurveBetasByIteration, selectedTheoryIndices)
    import CBT.TheoryComparison.ResultAnalysis.UI.plot_selected_hists_and_gumbels_in_tabs;

    numSelectedTheories = length(selectedTheoryIndices);
    for selectedTheoryNum=1:numSelectedTheories
        selectedTheoryName = theoryNames{selectedTheoryIndices(selectedTheoryNum)};
        fprintf('%s - Plotting histogram & gumbel...\n', selectedTheoryName);
        selectedTheoryIndex = selectedTheoryIndices(selectedTheoryNum);
        plot_selected_hists_and_gumbels_in_tabs(tsHistAndGumbel, theoryNames, bestCCs, gumbelCurveMusByIteration, gumbelCurveBetasByIteration, selectedTheoryIndex);
    end
end