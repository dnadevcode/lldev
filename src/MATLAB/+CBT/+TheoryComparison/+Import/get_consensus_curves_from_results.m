function [aborted, consensusBarcodeNames, consensusBarcodeStructs] = get_consensus_curves_from_results()
    % get_consensus_curves_from_results
    %
    % TODO: make this compatible with HCA structure.
    import Fancy.Utils.data_hash;

    consensusBarcodeNames = cell(0, 1);
    consensusBarcodeStructs = cell(0, 1);
    
    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    defaultConsensusDirpath = fullfile(appDirpath, 'OutputFiles', 'Consensus');
    [filename, dirpath] = uigetfile({'*.mat;'}, 'Select DBM Consensus Results File for Exp Data Import', defaultConsensusDirpath,'MultiSelect', 'on');

    if ~iscell(filename) % in case single file only
        filenameTemp = filename;
        filename = [];
        filename = {filenameTemp};
    end
    
    aborted = isequal(dirpath, 0);
    if aborted
        return;
    end
    
    idx = 1;
    for k =1:length(filename)
        filepath = fullfile(dirpath, filename{k});
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
            consensusBarcodeStructs{idx} = consensusBarcodeStruct;
            idx = idx+1;
        end
        
    end
	consensusBarcodeNames = cellfun(@(x) x.displayName, consensusBarcodeStructs, 'UniformOutput', false);
    
    aborted = false;
end
