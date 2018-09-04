function [] = plot_contig_placements(...
        hAxis, ...
        plotTitleStr, ...
        refBarcode, ...
        refContigPlacementValsMat, ...
        kbpsPerPixel, ...
        refBarcodeLabel, ...
        placedContigLabels, ...
        placedContigColorTriplets, ...
        refBarcodeColorTriplet ...
    )
    numPlacedContigs = size(refContigPlacementValsMat, 2);
    if nargin < 8
        % Choosing colors for the contigs
        import ThirdParty.DistinguishableColors.distinguishable_colors;
        placedContigColorTriplets = distinguishable_colors(numPlacedContigs, [0 0 0; 1 1 1]);
    end
    if nargin < 9
        refBarcodeColorTriplet = [0 0 0];
    end
    set(hAxis, ...
        'ColorOrder', [refBarcodeColorTriplet; placedContigColorTriplets], ...
        'ColorOrderIndex', 1);

    plot(hAxis, refBarcode);
    hold(hAxis, 'on');
    plot(hAxis, refContigPlacementValsMat);

    refBarcodeLen = length(refBarcode);
    xlim(hAxis, [1, refBarcodeLen]);
    ylim(hAxis, round([min(refBarcode), max(refBarcode)] .* [(1/1.15), 1.15]));

    xlabel(hAxis, 'Position (kbps)');
    ylabel(hAxis, 'Rescaled intensity');
    title(hAxis, plotTitleStr);
    
    legendLabelStrs = [{refBarcodeLabel}; placedContigLabels(:)];
    legend(hAxis, legendLabelStrs, 'Location', 'Best');

    xPos_Kbps = round(linspace(0, round(refBarcodeLen * kbpsPerPixel), refBarcodeLen));
    xTickVals_pixelIdxs = round(cellfun(@str2double, get(hAxis, 'XTickLabel')));
    xTickVals_pixelIdxs(isnan(xTickVals_pixelIdxs)) = [];
    xTickVals_kbps = xPos_Kbps(xTickVals_pixelIdxs);
    set(hAxis, 'XTickLabel', xTickVals_kbps);
end