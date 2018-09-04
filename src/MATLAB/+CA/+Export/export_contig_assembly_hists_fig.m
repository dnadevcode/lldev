function [] = export_contig_assembly_hists_fig(histS)
    % Recreates the histogram from CAT tree program to be able to
    % save it.
    hFigTmp = figure();
    hPanelTmp = uipanel('Parent', hFigTmp);
    hAxisTmp = axes('Parent', hPanelTmp);

    import CA.UI.plot_hists;
    plot_hists(hAxisTmp, histS);

    [figFilename, dirpath] = uiputfile('*.fig', 'Save As');
    figFilepath = fullfile(dirpath, figFilename);
    saveas(hFigTmp, figFilepath, 'fig');
    close(hFigTmp);
end