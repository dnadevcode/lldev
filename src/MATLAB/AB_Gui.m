function hFig = AB_Gui(settings)
    if nargin < 1
        settings = struct();
    end
    import AB.UI.get_valid_settings;
    [successTF, settings] = get_valid_settings(settings);
    if not(successTF)
        return;
    end
    
    % AB_GUI - Autobarcoder GUI
    hFig = figure(...
        'Name', 'AutoBarcoder GUI', ...
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

    hTabAB = ts.create_tab('AutoBarcoder');
    ts.select_tab(hTabAB);
    hPanelAB = uipanel('Parent', hTabAB);
    tsAB = TabbedScreen(hPanelAB);
    
    
    import AB.UI.add_autobarcoder_menu;
    add_autobarcoder_menu(hMenuParent, tsAB, settings);
    import AB.UI.run_movie_to_kymos;
    run_movie_to_kymos(tsAB, settings);
end