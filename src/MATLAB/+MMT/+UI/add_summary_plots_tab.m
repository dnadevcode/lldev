function [] = add_summary_plots_tab(ts, meltmapBarcodes_bpRes_prePSF, temperatures_Celsius, sharedSaltConc_molar)
    import ThirdParty.DistinguishableColors.distinguishable_colors;
    tabTitleText = sprintf('Unmelted prob. profiles summary (%g M)', sharedSaltConc_molar);
    hTab = ts.create_tab(tabTitleText);
    ts.select_tab(hTab);
    hPanel = uipanel('Parent', hTab, 'Units', 'normalized', 'Position', [0 0 1 1]);
    hAxis = axes('Parent', hPanel, 'Units', 'normalized', 'Position', [0.1 0.4 0.8 0.5], 'FontSize', 12);

    numBarcodes = length(meltmapBarcodes_bpRes_prePSF);
    curveColors = distinguishable_colors(numBarcodes, [0 0 0; 1 1 1]);
    curveDisplayNames =  arrayfun(@(x) sprintf('(%g °C, %g M) Unmelted prob. profile', x, sharedSaltConc_molar), temperatures_Celsius(:), 'UniformOutput', false);

    for barcodeNum=1:numBarcodes
        plot(hAxis, ...
            meltmapBarcodes_bpRes_prePSF{barcodeNum}, ...
            'Color', curveColors(barcodeNum, :), ...
            'DisplayName', curveDisplayNames{barcodeNum});
        hold(hAxis, 'on');
    end
    legend(hAxis, 'show');

    xlabel(hAxis, 'Position (bp)', 'Fontsize', 12);
    ylabel(hAxis, 'Unmelted probability', 'Fontsize', 12);
end