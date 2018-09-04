function [consensusBarcodeNames, consensusBarcodes, consensusBitmasks, consensusFilepaths] = prompt_and_read_consensus_outputs(promptTitle, multiselectOn)
    if nargin < 1
        promptTitle = [];
    end
    if nargin < 2
        multiselectOn = true;
    end

    % Lets the user select several consensus files to use as the reference
    % barcodes for extreme value distribution generation.

    import OptMap.DataImport.try_prompt_consensus_filepaths;
    [~, consensusFilepaths] = try_prompt_consensus_filepaths(promptTitle, multiselectOn);
    [~, consensusBarcodeNames] = cellfun(@fileparts, consensusFilepaths, 'UniformOutput', false);
    
    import OptMap.DataImport.import_consensus_outputs_from_file;
    [consensusBarcodes, consensusBitmasks] = cellfun(@import_consensus_outputs_from_file, consensusFilepaths, 'UniformOutput', false);
end