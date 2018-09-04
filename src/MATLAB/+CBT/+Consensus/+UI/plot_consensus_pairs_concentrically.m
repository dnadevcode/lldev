function [] = plot_consensus_pairs_concentrically(clusterConsensusData)
    import Barcoding.Visualizing.plot_circular_barcodes_concentrically;
    import Barcoding.Helpers.sanitize_barcodes;
    import Fancy.UI.FancyTabs.TabbedScreen;

    clusterName = clusterConsensusData.clusterKey;
    import CBT.Consensus.Helper.extract_pairings;
    pairings = extract_pairings(clusterConsensusData);
    numPairings = length(pairings);
    figureName = sprintf('Pairwise Consensus of Cluster %s (Concentric Plots)', clusterName);
    hFig = figure( ...
        'Name', figureName, ...
        'Units', 'normalized', ...
        'OuterPosition', [0 0.05 1 0.95], ...
        'MenuBar', 'none', ...
        'ToolBar', 'none');
    hPanel = uipanel('Parent', hFig);
    ts = TabbedScreen(hPanel);

    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    defaultPngDirpath = appDirpath;
    pngDirpath = uigetdir(defaultPngDirpath, 'Pick a directory to output png files to');

    set(hFig, 'PaperPositionMode', 'auto');

    for pairingNum=1:numPairings
        pairing = pairings{pairingNum};
        namesData = {pairing.keyParentA; pairing.keyParentB; pairing.key};
        tabTitle = strrep(strrep(strjoin(flipud(namesData), ' vs '), '[', '('), ']', ')');
        hCurrPairingTab = ts.create_tab(tabTitle);
        ts.select_tab(hCurrPairingTab);
        hCurrPairingAxis = axes(...
            'Parent', hCurrPairingTab, ...
            'Units', 'normal', ...
            'Position', [0, 0.1, 0.6, 0.8]);

        % uitable(parentHandle,...
        %     'Data', namesData,...
        %     'ColumnName', {'Barcode Names (Numbered from center outwards)'},...
        %     'ColumnWidth', {400},...
        %     'Units', 'normal', 'Position', [0.6, 0, 0.4, 1]);
        plot_circular_barcodes_concentrically(hCurrPairingAxis, {pairing.alignedBarcodeParentA; pairing.alignedBarcodeParentB; pairing.barcode});

        if pngDirpath
            pngFilepath = fullfile(pngDirpath, [tabTitle, '.png']);
            print(hFig, '-dpng', '-r0', pngFilepath);
        end
    end

    import CBT.Consensus.Helper.extract_aligned_cluster_consensus_components;
    [alignedBarcodes, alignedBitmasks, clusterBarcodeKeys, clusterBarcodeAliases] = extract_aligned_cluster_consensus_components(clusterConsensusData);
    namesData = [clusterBarcodeKeys; {clusterConsensusData.clusterKey}];
    tabTitle = strrep(strrep(['COMBINATION - ', strjoin(flipud(namesData), ' vs ')], '[', '('), ']', ')');
    barcodes = [alignedBarcodes; {clusterConsensusData.barcode}];
    bitmasks = [alignedBitmasks; {clusterConsensusData.bitmask}];
    barcodes = sanitize_barcodes(barcodes, bitmasks);

    hConsensusTab = ts.create_tab(tabTitle);
    ts.select_tab(hConsensusTab);
    hConsensusAxis = axes('Units', 'normal', 'Position', [0, 0.1, 0.6, 0.8], 'Parent', hConsensusTab);

    % uitable(parentHandle,...
    %     'Data', namesData,...
    %     'ColumnName', {'Barcode Names (Numbered from center outwards)'},...
    %     'ColumnWidth', {400},...
    %     'Units', 'normal', 'Position', [0.6, 0, 0.4, 1]);
    plot_circular_barcodes_concentrically(hConsensusAxis, barcodes);
    if pngDirpath
        print(hFig, '-dpng','-r0', [pngDirpath, tabTitle, '.png']);
    end
end