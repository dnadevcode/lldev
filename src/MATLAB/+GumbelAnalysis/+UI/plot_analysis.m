function [] = plot_analysis(hAxisHistAndGumbel, hAxisQuantileComparison, alpha, bestCCValues, useRecursiveApproachToGumbelFitting)
    import GumbelAnalysis.UI.display_anaysis_text;
    import GumbelAnalysis.UI.plot_quantile_comparison;
    import GumbelAnalysis.UI.plot_hist_and_gumbel;
    import GumbelAnalysis.Core.get_matches;
    import GumbelAnalysis.Core.compute_threshold_from_outlier_score;
    % import GumbelAnalysis.Core.p_value_error_info;
    import GumbelAnalysis.Core.bin_data_for_normalized_hist;
    import GumbelAnalysis.Core.get_gumbel_curve;
    import GumbelAnalysis.UI.prompt_should_export_gumble_curve_as_tsv;
    import GumbelAnalysis.Export.export_gumble_curve_as_tsv;

    bestCCValues = bestCCValues(:)';

    % --- Fit histogram of data to the Gumbel distribution ---
    [~, ~, gumbelCurveMusByIteration, gumbelCurveBetasByIteration, ~, ~] = get_matches(alpha, bestCCValues, 2);

    if useRecursiveApproachToGumbelFitting
        iterationIdx = numel(gumbelCurveMusByIteration);
    else
        iterationIdx = 1;
    end
    gumbelCurveMu = gumbelCurveMusByIteration{iterationIdx};
    gumbelCurveBeta = gumbelCurveBetasByIteration{iterationIdx};
    
    thresholdBestCC = compute_threshold_from_outlier_score(alpha, gumbelCurveMu, gumbelCurveBeta);

    % --- Calculate p-values for all plasmids ---
    pValues = 1 - exp(-exp(-(bestCCValues - gumbelCurveMu) ./ gumbelCurveBeta));  % P-value
    % [pValueUpperError, pValueLowerError, pValueUpperBounds, pValueLowerBounds] = p_value_error_info(bestCCValues, gumbelCurveMu, gumbelCurveBeta);

    % --- Make histogram of the bestCCs ---
    [binCenters, numBinElems, binWidth] = bin_data_for_normalized_hist(bestCCValues);
    binScaleFactor = gumbelCurveBeta / sum(numBinElems*binWidth);

    [gumbelCurveX, gumbelCurveY] = get_gumbel_curve(gumbelCurveMu, gumbelCurveBeta);

    if useRecursiveApproachToGumbelFitting
        histAndGumbelPlotTitle = 'Recursive Gumbel PDF for Best CCs';
    else
        histAndGumbelPlotTitle = 'Non-recursive Gumbel PDF for Best CCs';
    end
    plot_hist_and_gumbel(hAxisHistAndGumbel, histAndGumbelPlotTitle, binCenters, numBinElems, binScaleFactor, gumbelCurveX, gumbelCurveY, thresholdBestCC);
    
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    if useRecursiveApproachToGumbelFitting
        tsvFilepath = sprintf('recursiveGumbelCurve_%s.tsv', timestamp);
    else
        tsvFilepath = sprintf('nonrecursiveGumbelCurve_%s.tsv', timestamp);
    end
    [shouldSaveGumbelCurveTsv, tsvFilepath] = prompt_should_export_gumble_curve_as_tsv(plotTitle, tsvFilepath);
    if shouldSaveGumbelCurveTsv
        export_gumble_curve_as_tsv(tsvFilepath, gumbelCurveX, gumbelCurveY);
    end
    % --- Obtain the quantile function, z_j

    plot_quantile_comparison(hAxisQuantileComparison, bestCCValues, gumbelCurveBeta, gumbelCurveMu)

    display_anaysis_text(alpha, thresholdBestCC, pValues, bestCCValues, useRecursiveApproachToGumbelFitting);
end