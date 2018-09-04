function [] = ETE_Gui()
    % ETE_GUI - Experiment to Experiment (ETE) GUI for comparing 
    %  experiments against one other

    hFig = figure(...
        'Name', 'CB ETE Comparison', ...
        'Units', 'normalized', ...
        'OuterPosition', [0 0 1 1], ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none' ...
    );
    hMenuParent = hFig;
    hPanel = uipanel('Parent', hFig);
    import Fancy.UI.FancyTabs.TabbedScreen;
    ts = TabbedScreen(hPanel);
    
    hTabETE = ts.create_tab('ETE');
    ts.select_tab(hTabETE);
    hPanelETE = uipanel('Parent', hTabETE);
    tsETE = TabbedScreen(hPanelETE);
    
    import CBT.ExpComparison.UI.add_ete_menu;
    add_ete_menu(hMenuParent, tsETE);
end