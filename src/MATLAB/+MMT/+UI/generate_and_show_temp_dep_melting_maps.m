function [] = generate_and_show_temp_dep_melting_maps(ts)
    import MMT.Import.prompt_meltmap_params;
    [paramsAreValid, temperatures_Celsius, sharedSaltConc_Molar] = prompt_meltmap_params();
    if not(paramsAreValid)
        return;
    end

    import MMT.Import.prompt_dna_sequence;
    [theorySequence, theoryName] = prompt_dna_sequence();
    if isempty(theorySequence)
        return;
    end

    tabTitle = sprintf('(%s) MMT results', theoryName);
    hTab =  ts.create_tab(tabTitle);
    ts.select_tab(hTab);
    hPanel = uipanel('Parent', hTab, 'Units', 'normalized', 'Position', [0 0 1 1]);


    saltConc_Molar = sharedSaltConc_Molar;
    numTemperatures = length(temperatures_Celsius);
    meltmapBarcodes_bpRes_prePSF = cell(numTemperatures, 1);
    import MMT.Core.calculate_nonmelting_probs;
    for temperatureNum = 1:numTemperatures
        temperature_Celsius = temperatures_Celsius(temperatureNum);
        fprintf('Calculating unmelted prob. profile (%g °C, %g M)\n', temperature_Celsius, saltConc_Molar);

        doubleStrandedProbs_bpRes = calculate_nonmelting_probs(theorySequence, temperature_Celsius, saltConc_Molar);

        meltmapBarcodes_bpRes_prePSF{temperatureNum} = doubleStrandedProbs_bpRes;
    end

    import FancyGUI.FancyTabs.TabbedScreen;
    tsInner = TabbedScreen(hPanel);
    
    import MMT.UI.add_proto_barcodes_summary_tab;
    add_proto_barcodes_summary_tab(tsInner, meltmapBarcodes_bpRes_prePSF, temperatures_Celsius, sharedSaltConc_Molar);
    
    import MMT.UI.add_summary_plots_tab;
    add_summary_plots_tab(tsInner, meltmapBarcodes_bpRes_prePSF, temperatures_Celsius, sharedSaltConc_Molar);
    
    import MMT.UI.add_individual_plot_tabs;
    add_individual_plot_tabs(tsInner, meltmapBarcodes_bpRes_prePSF, temperatures_Celsius, sharedSaltConc_Molar);
end
