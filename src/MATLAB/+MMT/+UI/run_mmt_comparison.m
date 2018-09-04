function [] = run_mmt_comparison(tsMM, cache)
    if nargin < 2
    	cache = containers.Map();
        mmtSessionStruct = struct();
        cache('mmtSessionStruct') = mmtSessionStruct;
    end
    % This is for comparing MMT to MMT or MMT to theory
    
    tabTitle = 'Barcode vs theory similarity analysis';
    
    hTabBarcode = tsMM.create_tab(tabTitle);
    tsMM.select_tab(hTabBarcode);
    hPanelBarcode = uipanel(hTabBarcode);

    % import experimental maps
    import Fancy.UI.Templates.launch_barcode_import_ui;
    lm = launch_barcode_import_ui(hPanelBarcode, tsMM);
    
    % run similarity analysis
    import MMT.UI.on_run_similarity_analysis;
    cache = on_run_similarity_analysis(lm, tsMM);
% 
%     import MMT.UI.launch_barcode_import_ui;
%     lm = launch_barcode_import_ui(tsMM);

end