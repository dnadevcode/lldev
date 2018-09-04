function [consensusBarcode] = prompt_ref_barcode_consensus(promptTitle)
    if nargin < 1
        promptTitle = 'Reference consensus barcode file';
    end

    import OptMap.DataImport.prompt_and_read_consensus_outputs;
    [~, consensusBarcodes, ~, ~] = prompt_and_read_consensus_outputs(promptTitle, false);

    if isempty(consensusBarcodes)
        consensusBarcode = [];
        % consensusBitmask = [];
        % consensusFilepath = [];
        return;
    end
    consensusBarcode = consensusBarcodes{1};
    % consensusBitmask = consensusBitmasks{1};
    % consensusFilepath = consensusFilepaths{1};
end