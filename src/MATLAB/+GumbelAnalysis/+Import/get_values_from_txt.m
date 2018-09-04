function [aborted, values] = get_values_from_txt(valueTypeDescription)
    [filenames, dirpath] = uigetfile({'*.txt'}, ['Pick a text file containing ', valueTypeDescription], 'MultiSelect', 'off');
    
    aborted = isequal(dirpath, 0);
    if aborted
        values = [];
    else
        if not(iscell(filenames))
            filenames = {filenames};
        end
        filepaths = fullfile(dirpath, filenames);
        ccValuesFilepath = filepaths{1};
        values = load(ccValuesFilepath);
    end
end