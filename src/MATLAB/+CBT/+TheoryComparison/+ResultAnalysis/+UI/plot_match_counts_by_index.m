function [] = plot_match_counts_by_index(hAxisNumMatchesPlotByIndex, matchCounts)
    numTheories = length(matchCounts);

    fontSize = 14;

    bar(hAxisNumMatchesPlotByIndex, 1:numTheories, matchCounts);
    xlim(hAxisNumMatchesPlotByIndex, [1, numTheories]);
    title(hAxisNumMatchesPlotByIndex, 'Number of Matches', 'FontSize', fontSize);
    xlabel(hAxisNumMatchesPlotByIndex, 'Plasmid Number', 'FontSize', fontSize);
    ylabel(hAxisNumMatchesPlotByIndex, 'Number of Matches', 'FontSize', fontSize);
end