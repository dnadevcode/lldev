function [] = DLC_Gui()
    % DLC_Gui(Densely Labelled Consensus, formerly CBC_GUI) - Densely labelled/Competitive Binding Consensing Matlab GUI for
    %  building a consensus barcode from experimental kymographs
    %  of DNA that has undergone competitive binding/melt mapping/etc with dense
    %  labeling
    %  
    %     Introduced in LLDEV 0.4.1
    %     Maybe: rename this to  (DLC), since labeling
    %     teqnique is not necessarily only consensus.

    hFig = figure(...
        'Name', 'Denslely labelled Consensing', ...
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
    
    hTabDLC = ts.create_tab('DLC');
    ts.select_tab(hTabDLC);
    hPanelDLC = uipanel('Parent', hTabDLC);
    tsDLC = TabbedScreen(hPanelDLC);

    import DLT.Consensus.UI.add_dlc_menu;
    add_dlc_menu(hMenuParent, tsDLC);
end