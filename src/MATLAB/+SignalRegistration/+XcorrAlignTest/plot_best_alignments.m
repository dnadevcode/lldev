function [] = plot_best_alignments(hPanel, seqA, seqB, aIndicesAtBestN, bIndicesAtBestN)
    numPlots = length(aIndicesAtBestN);
    numRows  = round(sqrt(numPlots));
    numCols = ceil(numPlots/round(sqrt(numPlots)));
    for plotNum = 1:numPlots
        hAxis = subplot(numRows, numCols, plotNum, 'Parent', hPanel);
        
        indicesA = aIndicesAtBestN{plotNum};
        indicesB = bIndicesAtBestN{plotNum};
        x = 1:length(indicesA);

        titleStr = sprintf('Sequence A (red) vs Sequence B (blue) - Alignment #%d', plotNum);
        title(hAxis, titleStr);
        plot(hAxis, x, seqA(indicesA), 'r-');
        hold(hAxis, 'on');
        plot(hAxis, x, seqB(indicesB), 'b-');
    end
end