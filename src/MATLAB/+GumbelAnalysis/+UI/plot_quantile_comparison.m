function [] = plot_quantile_comparison(hAxis, ccValues, gumbelCurveBeta, gumbelCurveMu)
    import GumbelAnalysis.Core.compute_threshold_from_outlier_score;
            
    numValues = length(ccValues);
    alphas = 1 - (0.5:(numValues - 0.5))/numValues;
    valueThresholds = compute_threshold_from_outlier_score(alphas, gumbelCurveMu, gumbelCurveBeta);

    % -- Quantile comparison plot
    lineWidth = 2;
    titleFontSize = 14;
    labelFontSize = 12;
    axisFontSize = 10;

    sortedCCs = sort(ccValues);
    plot(hAxis, valueThresholds, sortedCCs, 'ro', 'LineWidth', lineWidth);
    hold(hAxis, 'on');

    xLim = get(hAxis, 'XLim');
    yLim = get(hAxis, 'YLim');
    minLim = min(xLim(1), yLim(1));
    maxLim = max(xLim(2), yLim(2));

    plot(hAxis, [minLim, maxLim], [minLim, maxLim], 'k:', 'LineWidth', lineWidth); % straight line width slope 1
    hold(hAxis, 'on');
    % set(hAxis, 'XScale', 'log')
    % set(hAxis, 'YScale', 'log')
    xlabel(hAxis, 'z_j', 'FontSize', labelFontSize);
    ylabel(hAxis, 'Sorted Best CCs', 'FontSize', labelFontSize);

    set(hAxis, 'FontSize', axisFontSize);
    title(hAxis, 'Quantile Comparison', 'FontSize', titleFontSize);
    hold(hAxis, 'off');
end