function [] = run_similarity_analysis(tsETE)
    % run_similarity_analysis
    
    % input tsETE
    
    % Takes several experiments and compares them 
    % one to each other using phase-randomized barcodes
    % and also including bitmasks
    
    % edited by Albertas Dvirnas 05/10/17
    
    
    % create main tab for the analysis
    tabTitle = 'Barcode vs barcode similarity analysis';
    hTabBarcode = tsETE.create_tab(tabTitle);
    tsETE.select_tab(hTabBarcode);
    hPanelBarcode = uipanel(hTabBarcode);

    % import experimental maps
    import CBT.ExpComparison.UI.launch_barcode_import_ui;
    lm = launch_barcode_import_ui(hPanelBarcode, tsETE);

    % run similarity analysis
    import CBT.ExpComparison.UI.on_run_similarity_analysis;
    cache = on_run_similarity_analysis(lm, tsETE);
end