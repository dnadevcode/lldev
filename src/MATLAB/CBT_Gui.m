function [] = CBT_Gui()
    % CBT_GUI - Competitive Binding Theory (CBT) GUI
    %
    % CBT is tool for predicting Competitive Binding barcodes from
    %  underlying DNA sequence and match to either experiments, or a set of
    %  CB barcodes obtained from other DNA sequences.

    figureName = 'Competitive Binding Theory';
    hFig = figure(...
        'Name', figureName, ...
        'Units', 'normalized', ...
        'OuterPosition', [0 0.05 1 0.95], ...
        'MenuBar', 'none', ...
        'ToolBar', 'none' ...
        );
    hPanel = uipanel('Parent', hFig);

    import Fancy.UI.FancyTabs.TabbedScreen;
    ts = TabbedScreen(hPanel);

    import CBT.TheoryComparison.UI.make_main_theory_comparison_ui;
    make_main_theory_comparison_ui(ts);
end