function [] = add_individual_plot_tab(ts, meltmapBarcode_bpRes_prePSF, temperature_Celsius, saltConc_molar)
    tabTitleText = sprintf('Unmelted prob. profile (%g C, %g M)', temperature_Celsius-273.15, saltConc_molar);
    hTab = ts.create_tab(tabTitleText);
    ts.select_tab(hTab);
    hPanel = uipanel('Parent', hTab);
    hAxis = axes(...
        'Parent', hPanel, ...
        'Units', 'normalized', ...
        'Position', [0.1 0.4 0.8 0.5], ...
        'FontSize', 12);

    plot(hAxis, meltmapBarcode_bpRes_prePSF, 'b', 'Linewidth', 2);
    xlabel(hAxis, 'Position (bp)', 'Fontsize', 12);
    ylabel(hAxis, 'Unmelted probability', 'Fontsize', 12);

    hButtonSaveTxt = uicontrol('Parent', hPanel, 'Style', 'pushbutton', 'String', 'Save unmelted prob profile (txt)', 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.1]);
    
    import MMT.Export.export_unmelted_prob_profiles_txt;
    set(hButtonSaveTxt, 'Callback', @(~, ~) export_unmelted_prob_profiles_txt(meltmapBarcode_bpRes_prePSF, temperature_Celsius, saltConc_molar));
end