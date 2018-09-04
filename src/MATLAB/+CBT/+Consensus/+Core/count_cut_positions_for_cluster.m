function [posEndCounts, posEndCountsPreCut] = count_cut_positions_for_cluster(clusterConsensusData)
    clusterResultStruct = clusterConsensusData.clusterResultStruct;
    barcodeLens = cellfun(@length, clusterResultStruct.barcodes);
    barcodeFlipTFs = clusterResultStruct.flipTFs;
    barcodeCircShifts = clusterResultStruct.circShifts;
    
    import CBT.Consensus.Core.count_cut_positions;
    [posEndCounts, posEndCountsPreCut] = count_cut_positions(barcodeLens, barcodeFlipTFs, barcodeCircShifts);
end