function CAT_Gui()
    % CAT_GUI - Contig Assembly (CA) Theory GUI

    hFig = figure(...
        'Name', 'Contig Assembly GUI', ...
        'Units', 'normalized', ...
        'OuterPosition', [0.05 0.05 0.9 0.9], ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'ToolBar', 'none' ...
    );

    hMenuParent = hFig;
    hPanel = uipanel('Parent', hFig);
    import Fancy.UI.FancyTabs.TabbedScreen;
    ts = TabbedScreen(hPanel);
    
    hTabCA = ts.create_tab('CA');
    ts.select_tab(hTabCA);
    hPanelCA = uipanel('Parent', hTabCA);
    tsCA = TabbedScreen(hPanelCA);
    
    import CA.UI.add_contig_assembly_menu;
    add_contig_assembly_menu(hMenuParent, tsCA);
end