function [] = plot_match_counts_by_length(hAxisNumMatchesPlotByLength, matchCounts, theoryLengths_bp)
    validateattributes(theoryLengths_bp, {'numeric'}, {'finite', 'vector', 'nondecreasing'}, 1);

    numTheories = length(matchCounts);
    fontSize = 14;
    xTicks = round(linspace(1, numTheories, max(2, min(10, numTheories))));
    xTickLabels = arrayfun(@(idx) sprintf('%d kbp', round(theoryLengths_bp(idx)/1000)), xTicks, 'UniformOutput', false);

    bar(hAxisNumMatchesPlotByLength, 1:numTheories, matchCounts);
    xlim(hAxisNumMatchesPlotByLength, [1, numTheories]);
    title(hAxisNumMatchesPlotByLength, 'Number of Matches', 'FontSize', fontSize);
    xlabel(hAxisNumMatchesPlotByLength, 'Plasmid Lengths', 'FontSize', fontSize);
    ylabel(hAxisNumMatchesPlotByLength, 'Number of Matches', 'FontSize', fontSize);
    set(hAxisNumMatchesPlotByLength, ...
        'XTick', xTicks, ...
        'XTickLabel', xTickLabels, ...
        'XTickLabelRotation', 45);
end