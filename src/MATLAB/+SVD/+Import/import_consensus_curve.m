function [consensusCurve] = import_consensus_curve()
    promptTitle = 'Select Consensus File';
    [consensusFilename, consensusDirpath] = uigetfile({'*.mat;'; '*.txt;'}, promptTitle, 'MultiSelect', 'off');

    if isequal(consensusDirpath, 0)
        consensusCurve = [];
        return;
    end
    consensusFilepath = fullfile(consensusDirpath, consensusFilename);
    
    import OptMap.DataImport.import_consensus_outputs_from_file;
    [consensusBarcode, consensusBitmask] = import_consensus_outputs_from_file(consensusFilepath);
    consensusCurve = consensusBarcode;
    nanReplacementVal = nanmean(consensusBarcode(consensusBitmask));
    if isnan(nanReplacementVal)
        nanReplacementVal = 0;
    end
    consensusCurve(isnan(consensusCurve)) = nanReplacementVal;
end