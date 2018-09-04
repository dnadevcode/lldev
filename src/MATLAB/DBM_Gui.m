function [] = DBM_Gui()
    % DBM_GUI - DNA Barcode Matchmaker (DBM) GUI

    hFig = figure(...
        'Name', 'DNA Barcode Matchmaker', ...
        'Menubar', 'none', ...
        'NumberTitle', 'off', ...
        'Units','normalized', ...
        'Outerposition', [0.05, 0.05, 0.9, 0.9]);
    hMenuParent = hFig;

    hPanel = uipanel('Parent', hFig);
    import Fancy.UI.FancyTabs.TabbedScreen;
    ts = TabbedScreen(hPanel);
    
    
    hTabDBM = ts.create_tab('DBM');
    ts.select_tab(hTabDBM);
    hPanelDBM = uipanel('Parent', hTabDBM);
    tsDBM = TabbedScreen(hPanelDBM);

    import OldDBM.UI.add_dbm_menu;
    add_dbm_menu(hMenuParent, tsDBM);
end