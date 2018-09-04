function [consensusBarcode, consensusBitmask] = import_consensus_outputs_from_file(consensusFilepath)
    % Reads a consensus barcode from a file saved from automated consensus

    [~, ~, fileExt] = fileparts(consensusFilepath);
    if not(strcmpi(fileExt, '.mat'))
        import OptMap.DataImport.import_old_consensus_output_from_file;
        consensusBarcode = import_old_consensus_output_from_file(consensusFilepath);
        consensusBitmask = true(size(consensusBarcode));
        return;
    end

    dataStruct = load(consensusFilepath, 'clusterConsensusData');
    if not(isfield(dataStruct, 'clusterConsensusData')) ...
            || not(isfield(dataStruct.clusterConsensusData, 'barcode')) ...
            || not(isfield(dataStruct.clusterConsensusData, 'bitmask'))
        error('Unrecognized consensus file format');
    end
    consensusBarcode = dataStruct.clusterConsensusData.barcode;
    consensusBitmask = dataStruct.clusterConsensusData.bitmask;
end