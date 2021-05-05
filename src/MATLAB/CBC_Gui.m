function [] = CBC_Gui(runGui)
    % CBC_Gui - Competitive Binding Consensing Matlab GUI for
    %  building a consensus barcode from experimental kymographs
    %  of DNA that has undergone competitive binding with dense
    %  labeling

    if nargin < 1 || runGui == 1
        % old structure: GUI
        hFig = figure(...
            'Name', 'Competitive Binding Consensing', ...
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

        hTabCBC = ts.create_tab('CBC');
        ts.select_tab(hTabCBC);
        hPanelCBC = uipanel('Parent', hTabCBC);
        tsCBC = TabbedScreen(hPanelCBC);

        import CBT.Consensus.UI.add_cbc_menu;
        add_cbc_menu(hMenuParent, tsCBC);
        
    else
        % runs the same as GUI but without any prompts - suitable for
        % cluster computing
        
        
    end
end