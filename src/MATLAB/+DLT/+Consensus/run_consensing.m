function [] = run_consensing(tsDLC)
    % run consensing
    tabTitle = 'Kymos for Consensus';
    hTabKymoImport = tsDLC.create_tab(tabTitle);
    tsDLC.select_tab(hTabKymoImport);
    hPanelKymoImport = uipanel(hTabKymoImport);

    import CBT.Consensus.UI.launch_kymo_import_ui;
    lm = launch_kymo_import_ui(hPanelKymoImport, tsDLC);

    import CBT.Consensus.UI.add_consensus_btns_to_kymo_list_mgr;
    add_consensus_btns_to_kymo_list_mgr(lm, tsDLC);
end