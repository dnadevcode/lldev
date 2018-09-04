function [] = plot_pvalue_heatmap(hAxisPvalHeatmap, pValMat)
    imagesc(pValMat, 'Parent', hAxisPvalHeatmap);
    set(hAxisPvalHeatmap, ...
        'YTick', 1:size(pValMat, 1),...
        'XTick', 1:size(pValMat, 2), ...
        'YDir', 'reverse', ...
        'XDir', 'normal');

    title(hAxisPvalHeatmap, 'P-value')
    xlabel(hAxisPvalHeatmap, 'Barcode index');
    ylabel(hAxisPvalHeatmap, 'Barcode index');
    colorbar(hAxisPvalHeatmap);
    caxis(hAxisPvalHeatmap, [0 1]);
end