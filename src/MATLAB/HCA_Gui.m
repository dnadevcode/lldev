 function [] = HCA_Gui()
    % HCA_GUI - Human chromosome assembly (HCA) GUI for comparing 
    %  fagments of human chromosome to chromosomes using CB (competitive
    %  binding) theory

    % loads figure window
    hFig = figure(...
        'Name', 'CB HCA tool', ...
        'Units', 'normalized', ...
        'OuterPosition', [0 0 1 1], ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none' ...
    );
    hMenuParent = hFig;
    hPanel = uipanel('Parent', hFig);
    import Fancy.UI.FancyTabs.TabbedScreen;
    ts = TabbedScreen(hPanel);
    
    hTabHCA = ts.create_tab('HCA');
    ts.select_tab(hTabHCA);
    hPanelHCA = uipanel('Parent', hTabHCA);
    tsHCA = TabbedScreen(hPanelHCA);
    
    % add main tab with hca tool
    import CBT.Hca.UI.add_hca_menu;
    add_hca_menu(hMenuParent, tsHCA);
end