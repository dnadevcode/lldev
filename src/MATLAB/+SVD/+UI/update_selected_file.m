function [] = update_selected_file(hEditSelectedFile)
    % TODO: split into more strictly defined components
    %  e.g. separate potential consensus barcode prompt from
    %      sequence prompt, standardize to import of barcode
    [filename, dirpath, ~] = uigetfile({'*.mat;*.fasta'}, 'Select File for Barcode Acquisition', 'MultiSelect','off');
    if isequal(dirpath, 0)
        return;
    end
    filepath = fullfile(dirpath, filename);
    set(hEditSelectedFile, 'String', filepath);
end