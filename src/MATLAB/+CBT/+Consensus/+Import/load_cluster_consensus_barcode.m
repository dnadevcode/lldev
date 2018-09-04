function [barcode, bitmask] = load_cluster_consensus_barcode(consensusMatFilepath)
    if nargin < 1
       consensusMatFilepath = [];
    end
    
    import CBT.Consensus.Import.load_cluster_consensus;
    clusterConsensusData = load_cluster_consensus(consensusMatFilepath);
    barcode = [];
    if isfield(clusterConsensusData, 'barcode')
        barcode = clusterConsensusData.barcode;
    end
    bitmask = [];
    if isfield(clusterConsensusData, 'bitmask')
        bitmask = clusterConsensusData.bitmask;
    end
end