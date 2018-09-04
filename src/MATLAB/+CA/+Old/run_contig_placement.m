function [] = run_contig_placement(tsCA, consensusBarcode, consensusBarcodeName, unscaledContigBarcodes)
    % RUN_CONTIG_PLACEMENT - places several short theoretical barcode on
    % experiments and consensus
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
        import CA.Old.Core.gen_unscaled_barcodes;
        unscaledContigBarcodes = gen_unscaled_barcodes();
    end

    aggregatedContigBarcodes = horzcat(unscaledContigBarcodes{:});

    globalContigBarcodeMean = nanmean(aggregatedContigBarcodes);
    globalContigBarcodeStd = nanstd(aggregatedContigBarcodes);


    rescaledContigBarcodes = cellfun(@(barcode) (barcode - globalContigBarcodeMean)./globalContigBarcodeStd, unscaledContigBarcodes, 'UniformOutput', false);
    [~, reordering] = sort(cellfun(@length, rescaledContigBarcodes), 'descend');
    rescaledContigBarcodes = rescaledContigBarcodes(reordering);


    rescaledConcensusBarcode = zscore(consensusBarcode);

    import CA.Old.Core.find_contig_placements;
    placedContigBarcodes = find_contig_placements(rescaledContigBarcodes, rescaledConcensusBarcode);
    
    
    tabTitle = 'Erik''s Contig Assembly (Contig Placements)';
    hTabECACP = tsCA.create_tab(tabTitle);
    tsCA.select_tab(hTabECACP);
    hPanelECACP = uipanel('Parent', hTabECACP);
    
    hAxis = axes('Parent', hPanelECACP);
    import CA.Old.UI.plot_contig_placements;
    plot_contig_placements(hAxis, placedContigBarcodes, rescaledConcensusBarcode, consensusBarcodeName);
    
    
    import CA.Old.Import.prompt_should_save_txt;
    shouldSaveTxt = prompt_should_save_txt();
    if shouldSaveTxt
        import CA.Old.Export.export_contig_placement_txt;
        export_contig_placement_txt(placedContigBarcodes, rescaledConcensusBarcode, consensusBarcodeName);
    end
end