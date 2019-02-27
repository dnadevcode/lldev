function [ lm ] = create_import_tab( tsHCC, tabTitle )
    % create_import_tab 

    % create main tab for the analysis
    hTabKymoImport = tsHCC.create_tab(tabTitle);
    tsHCC.select_tab(hTabKymoImport);
    hPanelKymoImport = uipanel(hTabKymoImport);

    % import kymographs
    import Fancy.UI.Templates.launch_kymo_import_ui;
    lm = launch_kymo_import_ui(hPanelKymoImport, tsHCC);
end

