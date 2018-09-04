function [] = MMT_Gui()
    % MMT_GUI - Melting Map Theory (MMT) GUI for predicting
    % DNA melt maps from underlying DNA sequence
    
    % use "Symbol" font and latex interpreter for text
    set(0,'defaulttextinterpreter','latex')
     
    hFig = figure(...
        'Name', 'DNA Melting Maps Tool', ...
        'Units', 'normalized', ...
        'OuterPosition', [0 0 1 1], ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none' ...
        );
    hMenuParent = hFig; 

    hPanel = uipanel('Parent', hFig);
    import FancyGUI.FancyTabs.TabbedScreen;
    ts = TabbedScreen(hPanel);
    
    hTabMMT = ts.create_tab('MMT');
    ts.select_tab(hTabMMT);
    hPanelMMT = uipanel('Parent', hTabMMT);
    tsMM = TabbedScreen(hPanelMMT);

    import MMT.UI.add_mmt_ui;
    add_mmt_ui(hMenuParent, tsMM);
end
