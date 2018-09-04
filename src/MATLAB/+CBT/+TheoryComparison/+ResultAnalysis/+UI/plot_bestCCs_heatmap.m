function [] = plot_bestCCs_heatmap(hAxisIntensityPlot, bestCCsMat, theoryLengths_bp)
    import CBT.TheoryComparison.ResultAnalysis.UI.Helper.get_theory_len_tick_label_maker;

    matSize = size(bestCCsMat);

    colormapStr = 'hot';
    axisFontSize = 14.0;
    xTicksCount = 10;
    yTicksCount = 10;
    xTickLabelRotation = 45.0;
    fn_theory_len_tick_labeler = get_theory_len_tick_label_maker(theoryLengths_bp);
    fn_x_tick_labeler = fn_theory_len_tick_labeler;
    fn_y_tick_labeler = fn_theory_len_tick_labeler;
    xTicks = 1:floor((matSize(2) - 1)/(xTicksCount - 1)):matSize(2);
    yTicks = 1:floor((matSize(1) - 1)/(yTicksCount - 1)):matSize(1);
    xTickLabels = arrayfun(fn_x_tick_labeler, xTicks, 'UniformOutput', false);
    yTickLabels = arrayfun(fn_y_tick_labeler, yTicks, 'UniformOutput', false);

    % titleText = '';
    % titleTextInterpreter = 'latex';
    % titleTextFontSize = 16;
    % if not(isempty((titleText)))
    %     title(hAxisIntensityPlot, titleText,...
    %         'Interpreter', titleTextInterpreter,...
    %         'FontSize', titleTextFontSize);
    % end

    colormap(hAxisIntensityPlot, colormapStr);
    axes(hAxisIntensityPlot);
    imagesc(bestCCsMat, 'Parent', hAxisIntensityPlot);
    axis(hAxisIntensityPlot, 'square');
    set(hAxisIntensityPlot, ...
        'YDir', 'normal', ...
        'XTick', xTicks, ...
        'XTickLabelRotation', xTickLabelRotation, ...
        'XTickLabel', xTickLabels, ...
        'YTick', yTicks, ...
        'YTickLabel', yTickLabels, ...
        'FontSize', axisFontSize, ...
        'TickLabelInterpreter','tex');

    [~] = colorbar('peer', hAxisIntensityPlot, 'TickDirection', 'out');
end