function [] = plot_contig_placements_older(hAxis, contigPlacementsVect, refBarcode, contigBarcodes, sharedContigsLen, kbpsPerPixel, contigNames)
    import ThirdParty.DistinguishableColors.distinguishable_colors;
    % Plots the optimal path across the matrix

    contigPlacementsVect = contigPlacementsVect';

    refBarcodeLen = length(refBarcode);
    placedContigsMask = not(contigPlacementsVect == ((refBarcodeLen * 2) + 1));
    placedContigIdxs = find(placedContigsMask);


    % Prepare contigs
    numContigs = length(contigBarcodes);
    for contigNum = 1:numContigs
        if (contigPlacementsVect(contigNum) == (refBarcodeLen * 2) + 1)
            placedContigIdxs(contigNum) = 0;
        elseif (contigPlacementsVect(contigNum) > refBarcodeLen)
            contigBarcodes{contigNum} = fliplr(contigBarcodes{contigNum});
            contigPlacementsVect(contigNum) = contigPlacementsVect(contigNum) - refBarcodeLen;
        end
    end
    placedContigIdxs(placedContigIdxs == 0) = [];



    numContigs = length(placedContigIdxs);
    contigLengthsVect = repmat(sharedContigsLen, size(contigPlacementsVect));
    contigEndsVect = contigPlacementsVect + contigLengthsVect - 1;
    plotPiecewise = contigEndsVect > length(refBarcode);
    contigEndsVect(plotPiecewise) = 1 + mod(-1 + contigEndsVect(plotPiecewise), length(refBarcode));

    % Construct x-axis
    xPixel = 0:length(refBarcode)-1;
    xKbp = kbpsPerPixel*xPixel;



    % Colors
    triplet = distinguishable_colors(numContigs, [1 1 1; 0 0 0]);

    hPlotsVect = zeros(1, numContigs + 1);

    % Plot refCurve
    hPlotsVect(1) = plot(hAxis, ...
        xKbp, refBarcode, ...
        'Color', [0 0 0]);
    xlim(hAxis, [xKbp(1) xKbp(end)])
    xlabel(hAxis, 'Position (kbps)');
    ylabel(hAxis, 'Rescaled intensity');
    title(hAxis, sprintf('Contig Assembly Assignment method, using %d contigs', numContigs));
    hold(hAxis, 'on');

    % Plot contigs
    for contigIdx = placedContigIdxs
        contigColor = triplet(contigIdx, :);
        contigBarcode = contigBarcodes{contigIdx};
        if plotPiecewise(contigIdx)
            hContigPlot = plot(hAxis, ...
                xKbp(contigPlacementsVect(contigIdx):end), contigBarcode(1:end-contigEndsVect(contigIdx)), ...
                'Color', contigColor);
            plot(hAxis, xKbp(1:contigEndsVect(contigIdx)), contigBarcode(end-contigEndsVect(contigIdx)+1:end), ...
                'Color', contigColor)
        else
            hContigPlot = plot(hAxis, ...
                xKbp(contigPlacementsVect(contigIdx):contigEndsVect(contigIdx)), contigBarcode, ...
                'Color', contigColor);
        end
        hPlotsVect(contigIdx + 1) = hContigPlot;
    end
    legendLoc = 'Best';
    legend(hAxis, ...
        hPlotsVect, ['Consensus'; contigNames(:)], ...
        'Location', legendLoc)
end