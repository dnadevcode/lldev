function [] = MMT_Gui()
    % MMT_GUI - Melting Map Theory (MMT) GUI for predicting
    % DNA melt maps from underlying DNA sequence
    
    % TODO: should be similar structure to CBT Gui..
    
    hFig = figure(...
        'Name', 'Theoretical DNA Melting Maps', ...
        'Units', 'normalized', ...
        'OuterPosition', [0 0 1 1], ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none' ...
        );
    hMenuParent = hFig; 

    hPanel = uipanel('Parent', hFig);
    import Fancy.UI.FancyTabs.TabbedScreen;
    ts = TabbedScreen(hPanel);
    
    hTabMMT = ts.create_tab('MMT');
    ts.select_tab(hTabMMT);
    hPanelMMT = uipanel('Parent', hTabMMT);
    tsMMT = TabbedScreen(hPanelMMT);

    import MMT.UI.add_mmt_ui;
    add_mmt_ui(hMenuParent, tsMMT);
end
