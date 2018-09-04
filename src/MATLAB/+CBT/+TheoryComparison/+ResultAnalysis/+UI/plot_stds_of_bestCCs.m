function [] = plot_stds_of_bestCCs(hAxisStdPlot, stdOfBestCCsIncluded, theoryLengths_bp)
    import CBT.TheoryComparison.ResultAnalysis.UI.Helper.get_theory_len_tick_label_maker;
    fn_theory_len_tick_labeler = get_theory_len_tick_label_maker(theoryLengths_bp);
    numTheoryItems = length(theoryLengths_bp);
    xTicks = 1:floor((numTheoryItems - 1)/10):numTheoryItems;
    xTickLabels = arrayfun(fn_theory_len_tick_labeler, xTicks, 'UniformOutput', false);

    xLim = [1, numTheoryItems];
    xTickLabelRotation = 45.0;

    plot(hAxisStdPlot, stdOfBestCCsIncluded);
    xlim(hAxisStdPlot, xLim);
    xlabel(hAxisStdPlot, 'Plasmid Length');
    ylabel(hAxisStdPlot, 'Standard Deviation of Best Cross Correlation');
    set(hAxisStdPlot, ...
        'XTick', xTicks, ...
        'XTickLabelRotation', xTickLabelRotation, ...
        'XTickLabel', xTickLabels);
end