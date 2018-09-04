function [] = add_individual_plot_tabs(ts, meltmapBarcodes_bpRes_prePSF, temperatures_Celsius, sharedSaltConc_molar)
    tabTitleText = sprintf('Individual unmelted prob. profiles (%g M)', sharedSaltConc_molar);
   
    hTab = ts.create_tab(tabTitleText);
    ts.select_tab(hTab);
    hPanel = uipanel('Parent', hTab);
    
    import FancyGUI.FancyTabs.TabbedScreen;
    tsInner = TabbedScreen(hPanel);
    
    import MMT.UI.add_individual_plot_tab;
    numBarcodes = size(meltmapBarcodes_bpRes_prePSF, 1);
    for barcodeNum = 1:numBarcodes
        meltmapBarcode_bpRes_prePSF = meltmapBarcodes_bpRes_prePSF{barcodeNum};
        temperature = temperatures_Celsius(barcodeNum);
        saltConc_molar = sharedSaltConc_molar;
        add_individual_plot_tab(tsInner, meltmapBarcode_bpRes_prePSF, temperature, saltConc_molar);
    end
end