function [] = plot_selected_hists_and_gumbels_in_tabs(tsHistAndGumbel, theoryNames, histValuesMat, gumbelCurveMusByIteration, gumbelCurveBetasByIteration, selectedRowIndex)
    import GumbelAnalysis.Core.bin_data_for_normalized_hist;
    import GumbelAnalysis.Core.get_gumbel_curve;
    import GumbelAnalysis.UI.plot_hist_and_gumbel;
    import GumbelAnalysis.UI.prompt_should_export_gumble_curve_as_tsv;
    import GumbelAnalysis.Export.export_gumble_curve_as_tsv;

    theoryName = theoryNames{selectedRowIndex};

    % Get selected values
    histValues = histValuesMat(selectedRowIndex, :);
    histValues = histValues(~isnan(histValues)); % exclude NaNs

    % Get histogram data by binning selected values
    [binCentersX, binValuesY, binWidth] = bin_data_for_normalized_hist(histValues);

    gumbelCurveMusNonrecursive = gumbelCurveMusByIteration{1};
    gumbelCurveBetasNonrecursive = gumbelCurveBetasByIteration{1};
    gumbelCurveMusRecursive = gumbelCurveMusByIteration{end};
    gumbelCurveBetasRecursive = gumbelCurveBetasByIteration{end};

    for isRecursiveIdx=0:1
        isRecursive = logical(isRecursiveIdx);

        currTabTitle = theoryName;
        plotTitle = theoryName;
        if isRecursive
            currTabTitle = sprintf('%s (Recursive)', currTabTitle);
            plotTitle = sprintf('%s (Recursive)', plotTitle);
            gumbelCurveMus = gumbelCurveMusRecursive;
            gumbelCurveBetas = gumbelCurveBetasRecursive;
        else
            currTabTitle = sprintf('%s (Non-recursive)', currTabTitle);
            plotTitle = sprintf('%s (Non-recursive)', plotTitle);
            gumbelCurveMus = gumbelCurveMusNonrecursive;
            gumbelCurveBetas = gumbelCurveBetasNonrecursive;
        end
        gumbelCurveMu = gumbelCurveMus(selectedRowIndex);
        gumbelCurveBeta = gumbelCurveBetas(selectedRowIndex);


        % Get Gumbel curve from mus/betas
        [gumbelCurveX, gumbelCurveY] = get_gumbel_curve(gumbelCurveMu, gumbelCurveBeta);

        % Plot histogram and Gumbel 
        binScaleFactorY = gumbelCurveBeta / sum(binValuesY*binWidth);


        hTabCurr = tsHistAndGumbel.create_tab(currTabTitle);
        tsHistAndGumbel.select_tab(hTabCurr);
        hAxisHistAndCurvePlot = axes( ...
            'Parent', hTabCurr, ...
            'Units', 'normal', ...
            'Position', [0.1, 0.1, 0.8, 0.8]);
        plot_hist_and_gumbel(hAxisHistAndCurvePlot, plotTitle, binCentersX, binValuesY, binScaleFactorY, gumbelCurveX, gumbelCurveY);
        
        
        [shouldSaveGumbelCurveTsv, tsvFilepath] = prompt_should_export_gumble_curve_as_tsv(plotTitle, tsvFilepath);
        if shouldSaveGumbelCurveTsv
            export_gumble_curve_as_tsv(tsvFilepath, gumbelCurveX, gumbelCurveY);
        end

        % currTabFieldname = sprintf('hist_and_curve_%s', matlab.lang.makeValidName(theoryName));
        % if isRecursive
        %     currTabFieldname = sprintf('recursive_%s', currTabFieldname);
        % else
        %     currTabFieldname = sprintf('nonrecursive_%s', currTabFieldname);
        % end
        % tabHandles.(currTabFieldname) = currTabHandle;
        % tabNums.(currTabFieldname) = currTabNum;
    end
end