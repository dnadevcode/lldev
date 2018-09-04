function [] = measure_kymos_eld(tsELD, settings)
    tabTitle = 'Kymos for ELD analysis';
    hTabKymoImport = tsELD.create_tab(tabTitle);
    tsELD.select_tab(hTabKymoImport);
    hPanelKymoImport = uipanel(hTabKymoImport);

    import ELD.UI.launch_kymo_import_ui;
    lm = launch_kymo_import_ui(hPanelKymoImport, tsELD);

    import ELD.UI.add_eld_analysis_btns_to_kymo_list_mgr;
    add_eld_analysis_btns_to_kymo_list_mgr(lm, tsELD, settings);
end
