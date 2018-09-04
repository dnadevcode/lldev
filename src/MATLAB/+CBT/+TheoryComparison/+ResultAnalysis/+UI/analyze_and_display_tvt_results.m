function [] = analyze_and_display_tvt_results(tsResultAnalysis, resultsName, resultsStructTvT)
    import CBT.TheoryComparison.ResultAnalysis.Core.extract_tvt_results_data;
    [bestCCsRaw, theoryDataHashesRaw, theoryNamesRaw, theoryLengths_bpRaw] = extract_tvt_results_data(resultsStructTvT);
    
    import CBT.TheoryComparison.ResultAnalysis.UI.prompt_data_subset_selection;
    [theoryNames, bestCCsMat, theoryLengths_bp, theoryDataHashes] = prompt_data_subset_selection(bestCCsRaw, theoryDataHashesRaw, theoryNamesRaw, theoryLengths_bpRaw);

    import GumbelAnalysis.Import.prompt_alpha;
    alpha = prompt_alpha();
    
    fprintf('Fitting gumbel curves and finding matches...\n');
    import GumbelAnalysis.Core.get_matches;
    [matchMatricesByIteration, outlierScoresMatricesByIteration, gumbelCurveMusByIteration, gumbelCurveBetasByIteration] = get_matches(alpha, bestCCsMat, 2);

    outlierScoresMatrixNonrecursive = outlierScoresMatricesByIteration{1};
    outlierScoresMatrixRecursive = outlierScoresMatricesByIteration{end};


    % assignin('base', 'outlierScoresMatrixNonrecursive', outlierScoresMatrixNonrecursive);
    % assignin('base', 'outlierScoresMatrixRecursive', outlierScoresMatrixRecursive);


    import CBT.TheoryComparison.ResultAnalysis.UI.Helper.get_theory_len_tick_label_maker;
    import CBT.TheoryComparison.ResultAnalysis.UI.plot_bestCCs_heatmap;

    descriptonOfBestCC = 'Best Pearson Cross Correlation Values';
    fprintf('Plotting %s...\n', descriptonOfBestCC);
    tabTitleIntensityPlot = sprintf('%s [%dx%d]', descriptonOfBestCC, size(bestCCsMat, 1), size(bestCCsMat, 2));
    hTabTmp = tsResultAnalysis.create_tab(tabTitleIntensityPlot);
    tsResultAnalysis.select_tab(hTabTmp);
    hAxisIntensityPlot = axes('Units', 'normal', 'Position', [0.1, 0.1, 0.8, 0.8], 'Parent', hTabTmp);
    % tabFieldNameIntensityPlot = sprintf('bestCCs_%s', matlab.lang.makeValidName(resultsName));
    % hTabs.(tabFieldNameIntensityPlot) = hTabTmp;

    plot_bestCCs_heatmap(hAxisIntensityPlot, bestCCsMat, theoryLengths_bp);

    fprintf('Plotting Mean and Std of Best CC for %s\n', resultsName);
    tabTitleMeanAndStd = 'Mean and Std of Best CC';
    hTabTmp = tsResultAnalysis.create_tab(tabTitleMeanAndStd);
    tsResultAnalysis.select_tab(hTabTmp);
    hAxisMeanPlot = axes('Units', 'normal', 'Position', [0.1, 0.15, 0.375, 0.7], 'Parent', hTabTmp);
    hAxisStdPlot = axes('Units', 'normal', 'Position', [0.525, 0.15, 0.375, 0.7], 'Parent', hTabTmp);
    % tabFieldNameMeanAndStd = sprintf('meanAndStd_%s', matlab.lang.makeValidName(resultsName));
    % hTabs.(tabFieldNameMeanAndStd) = hTabTmp;



    meanOfBestCCsIncluded = nanmean(bestCCsMat, 2); % row-wise means excluding NaNs
    stdOfBestCCsIncluded = nanstd(bestCCsMat, 0, 2);% row-wise stds excluding NaNs 

    import CBT.TheoryComparison.ResultAnalysis.UI.prompt_should_export_mean_and_std;
    import CBT.TheoryComparison.ResultAnalysis.Export.export_mean_and_std_as_tsv;
    [shouldExportMeanAndStd, tsvFilepathMeanAndStd] = prompt_should_export_mean_and_std();
    if shouldExportMeanAndStd
        export_mean_and_std_as_tsv(tsvFilepathMeanAndStd, theoryNames, theoryLengths_bp, meanOfBestCCsIncluded, stdOfBestCCsIncluded);
    end

    import CBT.TheoryComparison.ResultAnalysis.UI.plot_means_of_bestCCs;
    import CBT.TheoryComparison.ResultAnalysis.UI.plot_stds_of_bestCCs;

    plot_means_of_bestCCs(hAxisMeanPlot, meanOfBestCCsIncluded, theoryLengths_bp);
    plot_stds_of_bestCCs(hAxisStdPlot, stdOfBestCCsIncluded, theoryLengths_bp);



    import CBT.TheoryComparison.ResultAnalysis.UI.prompt_should_export_num_iterations;
    import CBT.TheoryComparison.ResultAnalysis.Export.export_num_iterations_as_tsv;
    [shouldExportIterationsRecursive, tsvFilepathIterationsRecursive] = prompt_should_export_num_iterations(alpha);
    if shouldExportIterationsRecursive
        export_num_iterations_as_tsv(tsvFilepathIterationsRecursive, theoryNames, theoryLengths_bp, gumbelCurveMusByIteration, gumbelCurveBetasByIteration);
    end


    fprintf('Plotting overviews of match counts...\n');

    matchMatrixNonrecursive = matchMatricesByIteration{1};
    matchMatrixRecursive = matchMatricesByIteration{end};

    matchCountsNonrecursive = sum(matchMatrixNonrecursive, 2);
    matchCountsRecursive = sum(matchMatrixRecursive, 2);


    import CBT.TheoryComparison.ResultAnalysis.UI.panel_plot_and_graph_match_counts;
    tabTitleMatchCountsNonrecursive = sprintf('Match Counts (Non-recursive)');
    hTabTmp = tsResultAnalysis.create_tab(tabTitleMatchCountsNonrecursive);
    tsResultAnalysis.select_tab(hTabTmp);
    hParent = uipanel('Parent', hTabTmp);
    panel_plot_and_graph_match_counts(hParent, theoryLengths_bp, matchCountsNonrecursive);
    % tabFieldName = sprintf('match_counter__nonrecursive');
    % hTabs.(tabFieldName) = hTabTmp;


    import CBT.TheoryComparison.ResultAnalysis.UI.panel_plot_and_graph_match_counts;
    tabTitleMatchCountsRecursive = sprintf('Match Counts (Recursive with alpha = %g)', alpha);
    hTabTmp = tsResultAnalysis.create_tab(tabTitleMatchCountsRecursive);
    tsResultAnalysis.select_tab(hTabTmp);
    hParent = uipanel('Parent', hTabTmp);
    panel_plot_and_graph_match_counts(hParent, theoryLengths_bp, matchCountsRecursive);
    % tabFieldName = sprintf('match_counter_%s_recursive', matlab.lang.makeValidName(num2str(alpha)));
    % hTabs.(tabFieldName) = hTabTmp;



    import CBT.TheoryComparison.ResultAnalysis.UI.prompt_should_export_match_counts_tsv;
    [shouldExportMatchCountsNonrecursive, tsvFilepathNonrecursive] = prompt_should_export_match_counts_tsv(false);
    [shouldExportMatchCountsRecursive, tsvFilepathRecursive] = prompt_should_export_match_counts_tsv(true, alpha);


    import CBT.TheoryComparison.ResultAnalysis.Export.export_match_counts_tsv;
    if shouldExportMatchCountsNonrecursive
        export_match_counts_tsv(tsvFilepathNonrecursive, theoryNames, theoryLengths_bp, matchCountsNonrecursive);
    end
    if shouldExportMatchCountsRecursive
        export_match_counts_tsv(tsvFilepathRecursive, theoryNames, theoryLengths_bp, matchCountsRecursive);
    end


    import CBT.TheoryComparison.ResultAnalysis.UI.prompt_should_export_matches_nonrecursive;
    import CBT.TheoryComparison.ResultAnalysis.UI.prompt_should_export_matches_recursive;
    [shouldExportMatchesNonrecursive, tsvFilepathMatchesNonrecursive] = prompt_should_export_matches_nonrecursive();
    [shouldExportMatchesRecursive, tsvFilepathMatchesRecursive] = prompt_should_export_matches_recursive(alpha);

    import CBT.TheoryComparison.ResultAnalysis.Export.export_matches_as_tsv;
    if shouldExportMatchesNonrecursive
        export_matches_as_tsv(tsvFilepathMatchesNonrecursive, theoryNames, outlierScoresMatrixNonrecursive, matchMatrixNonrecursive);
    end
    if shouldExportMatchesRecursive
        export_matches_as_tsv(tsvFilepathMatchesRecursive, theoryNames, outlierScoresMatrixRecursive, matchMatrixRecursive);
    end

    fprintf('Plotting/Saving Lowest O-values...\n');
    nLowestOvals = 4;

    tabTitleNonrecursiveLowestOvals = sprintf('Lowest O-values (Non-recursive)');
    hTabTmp= tsResultAnalysis.create_tab(tabTitleNonrecursiveLowestOvals);
    tsResultAnalysis.select_tab(hTabTmp);
    hAxisLowestOvalsNonrecursive = axes('Units', 'normal', 'Position', [0.1, 0.1, 0.8, 0.8], 'Parent', hTabTmp);

    import CBT.TheoryComparison.ResultAnalysis.Core.extract_outlier_scores_matrix_lowest;
    import CBT.TheoryComparison.ResultAnalysis.UI.plot_n_lowest_o_vals;

    numEntries = size(outlierScoresMatrixNonrecursive, 1);
    [outlierScoresMatrixNonrecursiveLowest] = extract_outlier_scores_matrix_lowest(outlierScoresMatrixNonrecursive, nLowestOvals);
    plot_n_lowest_o_vals(hAxisLowestOvalsNonrecursive, numEntries, outlierScoresMatrixNonrecursiveLowest, nLowestOvals);

    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    defaultTsvDirpath = appDirpath;

    import CBT.TheoryComparison.ResultAnalysis.Core.make_lowest_ovals_nonrecursive_struct;
    import CBT.TheoryComparison.ResultAnalysis.UI.prompt_should_export_lowest_o_vals_nonrecursive;
    import Fancy.IO.TSV.write_tsv;

    [shouldExportLowestNonrecursive, tsvFilepathLowOvalsNonrecursive] = prompt_should_export_lowest_o_vals_nonrecursive(defaultTsvDirpath);
    if shouldExportLowestNonrecursive
        [lowestOValsNonrecursiveStruct, nonrecursiveFields] = make_lowest_ovals_nonrecursive_struct(theoryNames, theoryLengths_bp, outlierScoresMatrixNonrecursiveLowest);
        write_tsv(tsvFilepathLowOvalsNonrecursive, lowestOValsNonrecursiveStruct, nonrecursiveFields);
    end


    if not(isempty(tsvFilepathLowOvalsNonrecursive))
        defaultTsvDirpath = fileparts(tsvFilepathLowOvalsNonrecursive);
    end

    tabTitleLowestOvalsRecursive = sprintf('Lowest O-values (Recursive with alpha = %g)', alpha);
    hTabTmp = tsResultAnalysis.create_tab(tabTitleLowestOvalsRecursive);
    tsResultAnalysis.select_tab(hTabTmp);
    hAxisLowestOvalsRecursive = axes('Units', 'normal', 'Position', [0.1, 0.1, 0.8, 0.8], 'Parent', hTabTmp);
    [~] = generate_low_ovalue_scatterplots_recursive(hAxisLowestOvalsRecursive, theoryNames, theoryLengths_bp, outlierScoresMatrixRecursive, alpha, nLowestOvals, defaultTsvDirpath);


    import CBT.TheoryComparison.ResultAnalysis.Core.extract_outlier_scores_matrix_lowest;
    import CBT.TheoryComparison.ResultAnalysis.UI.plot_n_lowest_o_vals;

    numEntries = size(outlierScoresMatrixRecursive, 1);
    [outlierScoresMatrixRecursiveLowest] = extract_outlier_scores_matrix_lowest(outlierScoresMatrixRecursive, nLowestOvals);
    plot_n_lowest_o_vals(hAxisLowestOvalsRecursive, numEntries, outlierScoresMatrixRecursiveLowest, nLowestOvals, alpha);


    import CBT.TheoryComparison.ResultAnalysis.Core.make_lowest_ovals_recursive_struct;
    import CBT.TheoryComparison.ResultAnalysis.UI.prompt_should_export_lowest_o_vals_recursive;
    import Fancy.IO.TSV.write_tsv;

    [shouldExportLowestRecursive, tsvFilepathLowOvalsRecursive] = prompt_should_export_lowest_o_vals_recursive(alpha, defaultTsvDirpath);
    if shouldExportLowestRecursive
        [lowestOValsRecursiveStruct, recursiveFields] = make_lowest_ovals_recursive_struct(theoryNames, theoryLengths_bp, outlierScoresMatrixRecursiveLowest);
        write_tsv(tsvFilepathLowOvalsRecursive, lowestOValsRecursiveStruct, recursiveFields);
    end

    fprintf('Preparing theory selection screen for histogram and gumbel curve plotting...\n');

    hTabTmp = tsResultAnalysis.create_tab('Best CC Histograms with Gumbel Fits');
    tsResultAnalysis.select_tab(hTabTmp);
    hPanel = uipanel('Parent', hTabTmp);
    import Fancy.UI.FancyTabs.TabbedScreen;
    tsHistAndGumbel = TabbedScreen(hPanel);

    import CBT.TheoryComparison.ResultAnalysis.UI.make_selection_ui_for_plot_hist_and_gumbel;
    make_selection_ui_for_plot_hist_and_gumbel(tsHistAndGumbel, theoryNames, theoryDataHashes, theoryNamesRaw, theoryDataHashesRaw, bestCCsMat, gumbelCurveMusByIteration, gumbelCurveBetasByIteration);
end