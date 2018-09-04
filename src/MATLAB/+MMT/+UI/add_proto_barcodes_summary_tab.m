function [] = add_proto_barcodes_summary_tab(ts, meltmapBarcodes_bpRes_prePSF, temperatures_Celsius, sharedSaltConc_molar)
    tabTitleText = sprintf('Proto-barcodes summary (%g M)', sharedSaltConc_molar);
    hTab = ts.create_tab(tabTitleText);
    ts.select_tab(hTab);
    hPanel = uipanel('Parent', hTab, 'Units', 'normalized', 'Position', [0 0 1 1]);
    hAxis = axes('Parent', hPanel, 'Units', 'normalized', 'Position', [0.1 0.4 0.8 0.5], 'FontSize', 12);

    numBarcodes = length(meltmapBarcodes_bpRes_prePSF);
    maxBarcodeLen = max(cellfun(@length, meltmapBarcodes_bpRes_prePSF));
    meltmapBarcodesMat_bpRes_prePSF = NaN(numBarcodes, maxBarcodeLen);
    for barcodeNum = 1:numBarcodes
        meltmapBarcode_bpRes_prePSF = meltmapBarcodes_bpRes_prePSF{barcodeNum};
        meltmapBarcodesMat_bpRes_prePSF(barcodeNum, 1:length(meltmapBarcode_bpRes_prePSF)) = meltmapBarcode_bpRes_prePSF;
    end

    axes(hAxis);
    imagesc(meltmapBarcodesMat_bpRes_prePSF);

    yTicks = get(hAxis, 'ytick');
    yTicks = yTicks(mod(yTicks, 1) == 0); % remove non-integer y-ticks
    yTickLabels = arrayfun(@(temp) sprintf('%g °C', temp), temperatures_Celsius(yTicks), 'UniformOutput', false);

    set(hAxis,'ytick',yTicks);
    set(hAxis,'yticklabel', yTickLabels);
    xlabel(hAxis,'Position (bp)');
    ylabel(hAxis, 'Temperature (°C)');
    colormap(hAxis, gray);
end