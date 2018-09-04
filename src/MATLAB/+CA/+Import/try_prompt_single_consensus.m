function [aborted, consensusBarcodeName, consensusBarcode] = try_prompt_single_consensus()
    import OptMap.DataImport.prompt_and_read_consensus_outputs;
    [consensusBarcodeNames, consensusBarcodes, ~, ~] = prompt_and_read_consensus_outputs([], false);
    aborted = isempty(consensusBarcodeNames);
    if aborted
        consensusBarcodeName = '';
        consensusBarcode = [];
        return;
    end
    consensusBarcodeName = consensusBarcodeNames{1};
    consensusBarcode = consensusBarcodes{1};
end