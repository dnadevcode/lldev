function [] = plot_means_of_bestCCs(hAxisMeanPlot, meanOfBestCCsIncluded, theoryLengths_bp)
    import CBT.TheoryComparison.ResultAnalysis.UI.Helper.get_theory_len_tick_label_maker;
    fn_theory_len_tick_labeler = get_theory_len_tick_label_maker(theoryLengths_bp);
    numTheoryItems = length(theoryLengths_bp);
    xTicks = 1:floor((numTheoryItems - 1)/10):numTheoryItems;
    xTickLabels = arrayfun(fn_theory_len_tick_labeler, xTicks, 'UniformOutput', false);

    xLim = [1, numTheoryItems];
    xTickLabelRotation = 45.0;

    plot(hAxisMeanPlot, meanOfBestCCsIncluded);
    xlim(hAxisMeanPlot, xLim);
    xlabel(hAxisMeanPlot, 'Plasmid Length');
    ylabel(hAxisMeanPlot, 'Mean Best Cross Correlation');
    set(hAxisMeanPlot, ...
        'XTick', xTicks, ...
        'XTickLabelRotation', xTickLabelRotation, ...
        'XTickLabel', xTickLabels);
end