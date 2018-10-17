function hFig = ELD_Gui(settings)
    %ELD: Enzymatic Labeling Distances
    if nargin < 1
%         settings = struct();
%         settings.ELD = struct();
%         settings.ELD.minOverlap = 5; %TODO: put in settings file/prompt (positive integer)
%         settings.ELD.confidenceInterval = 2;
        import ELD.Import.load_eld_kymo_align_settings;
        settings = load_eld_kymo_align_settings();
    end
    
    % AB_GUI - Autobarcoder GUI
    hFig = figure(...
        'Name', 'Enzymatic Labeling Distances GUI', ...
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

    hTabELD = ts.create_tab('ELD');
    ts.select_tab(hTabELD);
    hPanelELD = uipanel('Parent', hTabELD);
    tsELD = TabbedScreen(hPanelELD);
    
    
    import ELD.UI.add_eld_menu;
    add_eld_menu(hMenuParent, tsELD, settings);
end