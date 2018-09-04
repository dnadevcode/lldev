function [posEndCounts, posEndCountsPreCut] = count_consensus_cuts(ts, clusterConsensusData, tsvOutputFilepath)
    posEndCounts = [];
    posEndCountsPreCut = [];
    if nargin < 1
        hFig = figure('Name', 'Consensus Cut Counts');
        hPanel = uipanel('Parent', hFig);
        ts = TabbedScreen(hPanel);
    end
    if nargin < 2
        import CBT.Consensus.Import.load_cluster_consensus;
        clusterConsensusData = load_cluster_consensus();
    end
    if isempty(clusterConsensusData)
        return;
    end
    import CBT.Consensus.Core.count_cut_positions_for_cluster;
    [posEndCounts, posEndCountsPreCut] = count_cut_positions_for_cluster(clusterConsensusData);
    if nargin < 3
        import CBT.Consensus.Import.prompt_consensus_ends_tsv_output_filepath;
        tsvOutputFilepath = prompt_consensus_ends_tsv_output_filepath();
    end

    if not(isempty(tsvOutputFilepath))
        dlmwrite(tsvOutputFilepath, posEndCounts, 'delimiter', '\t');
    end
    
    import CBT.Consensus.UI.add_consensus_cut_counts_tab;
    add_consensus_cut_counts_tab(ts, posEndCounts);
end