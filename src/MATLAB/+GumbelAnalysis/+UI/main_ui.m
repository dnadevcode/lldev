function main_ui()
    import GumbelAnalysis.Import.prompt_alpha;
    import GumbelAnalysis.Import.get_values_from_txt;
    import GumbelAnalysis.UI.plot_analysis;
    import Fancy.UI.FancyTabs.TabbedScreen;

    [aborted, bestCCValues] = get_values_from_txt('best CC values');
    if aborted
        return;
    end

    figName = 'Gumbel Analysis';
    hFig = figure( ...
        'Name', figName, ...
        'Units', 'normalized', ...
        'OuterPosition', [0 0.05 1 0.95], ...
        'MenuBar', 'none', ...
        'ToolBar', 'figure');
    import Fancy.UI.Toolbars.delete_all_other_toolbar_buttons;
    delete_all_other_toolbar_buttons(hFig, {...
        'Exploration.Pan';...
        'Exploration.ZoomOut';...
        'Exploration.ZoomIn';...
        'Standard.PrintFigure';...
        'Standard.SaveFigure'...
    });

    hPanel = uipanel('Parent', hFig);
    ts = TabbedScreen(hPanel);
    alpha = prompt_alpha();

    tabTitleHistAndGumbelPrefix = 'Hist & Gumbel';
    for useRecursiveApproachToGumbelFitting=0:1
        if useRecursiveApproachToGumbelFitting
            tabTitleHistAndGumbel = sprintf('%s (Recursive)', tabTitleHistAndGumbelPrefix);
        else
            tabTitleHistAndGumbel = sprintf('%s (Non-recursive)', tabTitleHistAndGumbelPrefix);
        end
        hTabTmp = ts.create_tab(tabTitleHistAndGumbel);
        ts.select_tab(hTabTmp);
        hAxisHistAndGumbel = axes('Units', 'normal', 'Position', [0.1, 0.1, 0.8, 0.8], 'Parent', hTabTmp);

        tabTitleQuantileComparison = 'Quantile Comparison';
        hTabTmp = ts.create_tab(tabTitleQuantileComparison);
        ts.select_tab(hTabTmp);
        hAxisQuantileComparison = axes('Units', 'normal', 'Position', [0.1, 0.1, 0.8, 0.8], 'Parent', hTabTmp);

        plot_analysis(hAxisHistAndGumbel, hAxisQuantileComparison, alpha, bestCCValues, useRecursiveApproachToGumbelFitting);
    end
end