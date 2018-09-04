function [] = ELT_Gui()
    % ELT_GUI - Enzymatic Labeling Theory (ELT) Matlab GUI

    hFig = figure(...
        'Name', 'ELT', ...
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
    
    hTabELT = ts.create_tab('ELT');
    ts.select_tab(hTabELT);
    hPanelELT = uipanel('Parent', hTabELT);
    tsELT = TabbedScreen(hPanelELT);

    import ELT.UI.add_elt_menu;
    add_elt_menu(hMenuParent, tsELT);
end