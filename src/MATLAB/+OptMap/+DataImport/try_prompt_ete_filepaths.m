function [aborted, eteFilepaths] = try_prompt_ete_filepaths(promptTitle, multiselectOn)
    if (nargin < 1)
        promptTitle = [];
    end
    if (nargin < 2) || isempty(promptTitle)
        multiselectOn = true;
    end
    if isempty(promptTitle)
        if multiselectOn
            promptTitle = 'Select ETE session Files';
        else
            promptTitle = 'Select ETE session File';
        end
    end
    if multiselectOn
        multiselectStr = 'on';
    else
        multiselectStr = 'off';
    end
    eteFilepaths = cell(0, 1);

    [eteFilenames, dirpath] = uigetfile({'*.mat;'; '*.txt;'}, promptTitle, 'MultiSelect', multiselectStr);

    aborted = isequal(dirpath, 0);
    if aborted
        return;
    end
    if not(iscell(eteFilenames))
        eteFilenames = {eteFilenames};
    end
    eteFilepaths = fullfile(dirpath, eteFilenames(:));
end