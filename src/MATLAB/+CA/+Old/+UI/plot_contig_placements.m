function [] = plot_contig_placements(hAxis, placedContigBarcodes, rescaledConcensusBarcode, consensusBarcodeName)
    titleStr = sprintf('Best place for contig on %s', consensusBarcodeName);

    plot(hAxis, rescaledConcensusBarcode, 'r-.', 'LineWidth', 2);
    hold(hAxis, 'on');
    for contigNum = 1:length(placedContigBarcodes)
        plot(hAxis, placedContigBarcodes{contigNum}, 'LineWidth', 2);
    end
    hold(hAxis, 'off');
    title(hAxis, titleStr, 'interpreter', 'none');
    xlabel(hAxis, 'Pixel index');
    ylabel(hAxis, 'Rescaled intensity');
end