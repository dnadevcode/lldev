function [] = run_single_contig_placement(tsCA, consensusBarcode, consensusBarcodeName, unscaledContigBarcode)
    % RUN_SINGLE_CONTIG_PLACEMENT - Places one short theoretical barcode
    % on experiments and consensus
    % 
    % Authors:
    %  Erik Lagerstedt
    %  Saair Quaderi (refactoring)

    
    if nargin < 3
        import CA.Import.try_prompt_single_consensus;
        [aborted, consensusBarcodeName, consensusBarcode] = try_prompt_single_consensus();
        if aborted
            return;
        end
    end

    if nargin < 4
        import CA.Old.Import.try_prompt_single_unscaled_contig_barcode;
        [aborted, unscaledContigBarcode] = try_prompt_single_unscaled_contig_barcode();
        if aborted
            return;
        end
    end

    import CA.Old.Import.acquire_rescale_factors;
    [rescaleMean, rescaleStd] = acquire_rescale_factors();
    rescaledContigBarcode = (unscaledContigBarcode - rescaleMean) ./ rescaleStd;

    rescaledConcensusBarcode = zscore(consensusBarcode);

    import CA.Old.Core.find_contig_placements;
    [placedContigBarcodes, bestCCs] = find_contig_placements({rescaledContigBarcode}, rescaledConcensusBarcode);
    placedContigBarcode = placedContigBarcodes{1};
    bestCC = bestCCs(1);

    tabTitle = 'Erik''s Contig Assembly (Single Contig Placement)';
    hTabECASCP = tsCA.create_tab(tabTitle);
    tsCA.select_tab(hTabECASCP);
    hPanelECASCP = uipanel('Parent', hTabECASCP);
    hAxis = axes('Parent', hPanelECASCP);
    
    import CA.Old.UI.plot_single_contig_placement;
    plot_single_contig_placement(hAxis, placedContigBarcode, rescaledConcensusBarcode, consensusBarcodeName, bestCC)


    import CA.Old.Import.prompt_should_save_txt;
    shouldSaveTxtTF = prompt_should_save_txt();

    % Handle response
    if shouldSaveTxtTF
        consensusBarcodeName = 'test';
        import CA.Old.Export.export_single_contig_placement_txt;
        export_single_contig_placement_txt(placedContigBarcode, rescaledConcensusBarcode, consensusBarcodeName);
    end
end