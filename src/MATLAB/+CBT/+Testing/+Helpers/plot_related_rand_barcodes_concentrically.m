function [] = plot_related_rand_barcodes_concentrically(hAxisCircPlot, baseBarcode, noiseMagnitude, numBarcodes, untrustedEdgeLength_pixels)
    if nargin < 1
        figureName = 'Aligned Barcodes (Concentric Plot)';
        hFig = figure(...
            'Name', figureName, ...
            'Units', 'normalized', ...
            'OuterPosition', [0 0.05 1 0.95], ...
            'MenuBar', 'none', ...
            'ToolBar', 'none' ...
        );
        hParentPanelCircPlot = uipanel('Parent', hFig);
        hAxisCircPlot = axes(...
            'Units', 'normal', ...
            'Position', [0, 0, 1, 1], ...
            'Parent', hParentPanelCircPlot ...
        );
    end
    if nargin < 2
        import CBT.RandBarcodeGen.SimplePSFRandomization.gen_rand_zscaled_barcode;
        baseBarcode = gen_rand_zscaled_barcode();
    end
    if nargin < 3
        noiseMagnitude = 0.4;
    end
    if nargin < 4
        numBarcodes = 1;
    end
    if nargin < 5
        import CBT.Bitmasking.calculate_untrusted_edge_len_pixels;
        untrustedEdgeLength_pixels = calculate_untrusted_edge_len_pixels();
    end
    

    import CBT.Testing.Helpers.get_some_noisy_barcodes;
    [unalignedBarcodes, flipTFs, circShifts] = get_some_noisy_barcodes(baseBarcode, noiseMagnitude, numBarcodes);
    unalignedBarcodeLens = cellfun(@length, unalignedBarcodes);
    
    import CBT.Bitmasking.generate_zero_edged_bitmask_row;
    unalignedBitmasks = arrayfun(...
        @(unalignedBarcodeLen) ...
            generate_zero_edged_bitmask_row(unalignedBarcodeLen, untrustedEdgeLength_pixels), ...
            unalignedBarcodeLens, ...
            'UniformOutput', false);
        
    alignedBarcodes = unalignedBarcodes;
    alignedBitmasks = unalignedBitmasks;

    import Barcoding.Reorienting.reorient_circ_indices;
    for barcodeNum=1:numBarcodes
        flipTF = flipTFs(barcodeNum);
        circShift = circShifts(barcodeNum);
        barcode = alignedBarcodes{barcodeNum};
        bitmask = alignedBitmasks{barcodeNum};
        len = length(barcode);
        alignedIndices = reorient_circ_indices(1:len, flipTF, circShift);
        alignedBarcodes{barcodeNum} = barcode(alignedIndices);
        alignedBitmasks{barcodeNum} = bitmask(alignedIndices);
    end

    import Barcoding.Helpers.sanitize_barcodes;
    sanitizedBarcodes = sanitize_barcodes(alignedBarcodes, alignedBitmasks);

    circPlotBarcodes = [baseBarcode; sanitizedBarcodes];

    import Barcoding.Visualizing.plot_circular_barcodes_concentrically;
    plot_circular_barcodes_concentrically(hAxisCircPlot, circPlotBarcodes);
    title(hAxisCircPlot, figureName);
end