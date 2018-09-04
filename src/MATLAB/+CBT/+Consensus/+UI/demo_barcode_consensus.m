function [consensusStruct, cache] = demo_barcode_consensus(rawBarcodes, displayNames, bpsPerPx_original, barcodeConsensusSettings, cache, tsCBC)
    if nargin < 2
        displayNames = {};
    end
    if nargin < 3
        bpsPerPx_original = [];
    end
    if nargin < 4
        barcodeConsensusSettings = [];
    end
    if nargin < 5
        cache = [];
    end
    if nargin < 6
        tsCBC = [];
    end
    if isempty(tsCBC)
        hFig = figure(...
            'Name', 'Competitive Binding Consensing', ...
            'Units', 'normalized', ...
            'OuterPosition', [0.05 0.05 0.9 0.9], ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'ToolBar', 'none' ...
        );

        hPanel = uipanel('Parent', hFig);
        import Fancy.UI.FancyTabs.TabbedScreen;
        ts = TabbedScreen(hPanel);

        hTabCBC = ts.create_tab('CBC');
        ts.select_tab(hTabCBC);
        hPanelCBC = uipanel('Parent', hTabCBC);
        tsCBC = TabbedScreen(hPanelCBC);
    end

    import CBT.Consensus.Core.generate_consensus_for_barcodes;
    [consensusStruct, cache] = generate_consensus_for_barcodes(rawBarcodes, displayNames, bpsPerPx_original, barcodeConsensusSettings, cache);
    
    import CBT.Consensus.Import.load_consensus_results;
    load_consensus_results(tsCBC, consensusStruct);
end