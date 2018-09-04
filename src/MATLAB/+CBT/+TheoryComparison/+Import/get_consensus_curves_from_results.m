function [aborted, consensusBarcodeNames, consensusBarcodeStructs] = get_consensus_curves_from_results()
    import Fancy.Utils.data_hash;

    consensusBarcodeNames = cell(0, 1);
    consensusBarcodeStructs = cell(0, 1);
    
    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    defaultConsensusDirpath = fullfile(appDirpath, 'OutputFiles', 'Consensus');
    [filename, dirpath] = uigetfile({'*.mat;'}, 'Select DBM Consensus Results File for Exp Data Import', defaultConsensusDirpath);

    aborted = isequal(dirpath, 0);
    if aborted
        return;
    end
    filepath = fullfile(dirpath, filename);
    consensusStruct = load(filepath);
    [~, fileName, fileExt] = fileparts(filepath);
    if isfield(consensusStruct, 'clusterConsensusData')
        clusterConsensusData = consensusStruct.clusterConsensusData;
        consensusBarcodeStruct = struct;
        consensusBarcodeStruct.displayName = ['Cluster Consensus from ', fileName, fileExt];
        consensusBarcodeStruct.experimentCurve_pxRes = clusterConsensusData.barcode;
        consensusBarcodeStruct.experimentCurveBitmask_pxRes = clusterConsensusData.bitmask;
        consensusBarcodeStruct.dataHash = data_hash({consensusBarcodeStruct.experimentCurve_pxRes, consensusBarcodeStruct.experimentCurveBitmask_pxRes});
        consensusBarcodeStruct.type = 'Cluster Consensus';
        consensusBarcodeStructs = {consensusBarcodeStruct};
        consensusBarcodeNames = cellfun(@(x) x.displayName, consensusBarcodeStructs, 'UniformOutput', false);
        return;
    end
    aborted = true;
end
