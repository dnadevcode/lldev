function [] = graph_match_counts_histogram(hAxisHistogramNumMatches, matchCounts)
    numTheories = length(matchCounts);

    fontSize = 14;
    binEdges = [0.5:1:8.5, inf];
    bins = 1:10;
    counts = histc(matchCounts(matchCounts > 0), binEdges);

    bar(hAxisHistogramNumMatches, bins, counts*100/numTheories);
    title(hAxisHistogramNumMatches, 'Percentage of Plasmids with Number of Matches', 'FontSize', fontSize);
    xlabel(hAxisHistogramNumMatches, 'Number of Matches', 'FontSize', fontSize);
    ylabel(hAxisHistogramNumMatches, 'Percentage of Plasmids', 'FontSize', fontSize);
end