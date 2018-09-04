function [aborted, filepaths] = prompt_filepaths_for_tvt_results(allowMultiselect)
    if nargin < 1
        allowMultiselect = true;
    end

    if allowMultiselect
        multiSelectStr = 'on';
    else
        multiSelectStr = 'off';
    end

    [filenames, dirpath] = uigetfile({'TvT_*.mat'}, 'Select Theory vs Theory Results File', 'MultiSelect', multiSelectStr);
    aborted = isequal(dirpath, 0);
    if aborted
        filepaths = cell(0, 1);
        return;
    end
    if not(iscell(filenames))
        filenames = {filenames};
    end
    filepaths = fullfile(dirpath, filenames);
end