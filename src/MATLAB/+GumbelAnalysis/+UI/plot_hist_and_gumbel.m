function [] = plot_hist_and_gumbel(hAxis, plotTitle, binCentersX, binValuesY, binScaleFactorY, gumbelCurveX, gumbelCurveY, threshold)
    if nargin < 8
        threshold = [];
    end
    plotTitle = strrep(plotTitle, '_', '\_');
    
    titleFontSize = 14;
    labelFontSize = 12;
    axisFontSize = 10;

    % -- Histogram of CCs
    set(hAxis, 'FontSize', 14);

    bar(hAxis, binCentersX, binValuesY*binScaleFactorY);
    hold(hAxis, 'on');

    plot(hAxis, gumbelCurveX, gumbelCurveY, 'r', 'Linewidth', 2);
    ylabel(hAxis, 'Probability Density', 'FontSize', labelFontSize);
    xlabel(hAxis, 'Best Cross-correlation', 'FontSize', labelFontSize);
    title(hAxis, plotTitle, 'FontSize', titleFontSize);
    set(hAxis, 'FontSize', axisFontSize);

    if not(isempty(threshold))
        thresholdX = [threshold, threshold];
        thresholdY = get(hAxis, 'YLim');
        plot(hAxis, thresholdX, thresholdY, 'k--', 'Linewidth', 2);
    end
    hold(hAxis, 'off');
end