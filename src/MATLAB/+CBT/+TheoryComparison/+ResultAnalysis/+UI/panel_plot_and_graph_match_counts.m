function [] =  panel_plot_and_graph_match_counts(hParent, theoryLengths_bp, matchCounts)

    hAxisNumMatchesPlotByIndex = axes('Units', 'normal', 'Position', [0.65, 0.1, 0.25, 0.8], 'Parent', hParent);
    hAxisNumMatchesPlotByLength = axes('Units', 'normal', 'Position', [0.35, 0.1, 0.25, 0.8], 'Parent', hParent);
    hAxisHistogramNumMatches = axes('Units', 'normal', 'Position', [0.05, 0.1, 0.25, 0.8], 'Parent', hParent);

    import CBT.TheoryComparison.ResultAnalysis.UI.plot_match_counts_by_index;
    plot_match_counts_by_index(hAxisNumMatchesPlotByIndex, matchCounts);
    
    import CBT.TheoryComparison.ResultAnalysis.UI.plot_match_counts_by_length;
    plot_match_counts_by_length(hAxisNumMatchesPlotByLength, matchCounts, theoryLengths_bp);
    
    import CBT.TheoryComparison.ResultAnalysis.UI.graph_match_counts_histogram;
    graph_match_counts_histogram(hAxisHistogramNumMatches, matchCounts);
end