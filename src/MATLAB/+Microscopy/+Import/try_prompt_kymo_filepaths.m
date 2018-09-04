function [aborted, srcMatFilepaths] = try_prompt_kymo_filepaths(promptTitle, multiselectOn, defaultFilepath)
    if nargin < 2
        multiselectOn = true;
    end
    if (nargin < 3) || isempty(defaultFilepath)
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        defaultFilepath = appDirpath;
    end
    if (nargin < 1) || isempty(promptTitle)
        if multiselectOn
            promptTitle = 'Select Kymo Mat Files';
        else
            promptTitle = 'Select Kymo Mat File';
        end
    end
    if multiselectOn
        multiselectStr = 'on';
    else
        multiselectStr = 'off';
    end
    srcMatFilepaths = cell(0, 1);

    [srcMatFilenames, dirpath] = uigetfile({'*.mat;'}, promptTitle, defaultFilepath, 'MultiSelect', multiselectStr);

    aborted = isequal(dirpath, 0);
    if aborted
        return;
    end
    if not(iscell(srcMatFilenames))
        srcMatFilenames = {srcMatFilenames};
    end
    srcMatFilepaths = fullfile(dirpath, srcMatFilenames(:));
end