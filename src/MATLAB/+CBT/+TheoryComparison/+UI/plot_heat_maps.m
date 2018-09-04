function [] = plot_heat_maps(ts, comparisonResultsByField)
    hTab = ts.create_tab('PCC');
    hPanel = uipanel('Parent', hTab);
    hAxisBestCC = subplot(2, 2, 1, 'Parent', hPanel);
    hAxisMeanCC = subplot(2, 2, 2, 'Parent', hPanel);
    hAxisStdCC = subplot(2, 2, 3, 'Parent', hPanel);
    
    colormap(hAxisBestCC, gray());
    axes(hAxisBestCC);
    imagesc(comparisonResultsByField.bestCC, [-1, 1]);
    title(hAxisBestCC, 'Max Pearson Correlation Coefficient');

    colormap(hAxisMeanCC, gray());
    axes(hAxisMeanCC);
    imagesc(comparisonResultsByField.meanCC, [-1, 1]);
    title(hAxisMeanCC, 'Pearson Correlation Coefficient Mean');

    colormap(hAxisStdCC, gray());
    axes(hAxisStdCC);
    imagesc(comparisonResultsByField.stdCC, [0, 1]);
    title(hAxisStdCC, 'Pearson Correlation Coefficient Standard Deviation');
end