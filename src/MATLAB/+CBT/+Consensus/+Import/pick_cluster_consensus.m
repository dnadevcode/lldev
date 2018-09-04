function [aborted, clusterKey] = pick_cluster_consensus(consensusStruct)
    clusterKeys = consensusStruct.clusterKeys;
    clusterKey = '';
    choice = menu('Pick a cluster', clusterKeys);
    aborted = all(choice == 0);
    if not(aborted)
        clusterKey = consensusStruct.clusterKeys{choice};
    end
end