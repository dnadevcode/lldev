function [aborted, clusterConsensusData] = export_cluster_consensus_mat(consensusStruct, clusterKey)
    aborted = false;
    if nargin < 2
        import CBT.Consensus.Import.pick_cluster_consensus;
        [aborted, clusterKey] = pick_cluster_consensus(consensusStruct);
        if aborted
            return;
        end
    end
    import CBT.Consensus.Export.Helper.get_default_consensus_dirpath;
    defaultConsensusDirpath = get_default_consensus_dirpath();
    timestamp = datestr(now, 'yyyy-mm-dd_HH_MM_SS');
    defaultConsensusFilename = sprintf('AC_%s_%s.mat', clusterKey, timestamp);
    defaultFilepath = fullfile(defaultConsensusDirpath, defaultConsensusFilename);
    [matFilename, dirpath, ~] = uiputfile('*.mat', 'Save Automatic Consensus Cluster Data As', defaultFilepath);
    if isequal(dirpath, 0)
        aborted = true;
        clusterConsensusData = [];
        return;
    end
    matFilepath = [dirpath, matFilename];
    clusterConsensusData.clusterKey = clusterKey;
    import CBT.Consensus.Helper.extract_cluster_deliverables;
    [...
        clusterConsensusData.barcode,...
        clusterConsensusData.bitmask,...
        clusterConsensusData.stdErrOfTheMean,...
        clusterConsensusData.indexWeights,...
        clusterConsensusData.clusterResultStruct,...
        ~...
    ] = extract_cluster_deliverables(consensusStruct, clusterKey);
    clusterConsensusData.details.consensusStruct = consensusStruct;
    save(matFilepath, 'clusterConsensusData');
    fprintf('Saved cluster consensus data for cluster ''%s'' to ''%s''\n', clusterKey, matFilepath);
end