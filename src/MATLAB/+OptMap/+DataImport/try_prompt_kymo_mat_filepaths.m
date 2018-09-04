function [aborted, kymoFilepaths] = try_prompt_kymo_mat_filepaths(promptTitle, allowMultiselect, defaultFilepath)
    if nargin < 1
        promptTitle = [];
    end
    if nargin < 2
        allowMultiselect = [];
    end
    if nargin < 3
        defaultFilepath = [];
    end
    if isempty(allowMultiselect)
        allowMultiselect = true;
    end
    if isempty(promptTitle)
        if allowMultiselect
            promptTitle = 'Select kymo mat files';
        else
            promptTitle = 'Select kymo mat file';
        end
    end
    if allowMultiselect
        multiSelectStr = 'on';
    else
        multiSelectStr = 'off';
    end
    filterSpec = {'*.mat;'};
    if isempty(defaultFilepath)
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        defaultFilepath = appDirpath;
    end

    [kymoFilenames, dirpath] = uigetfile(filterSpec, promptTitle, defaultFilepath, 'MultiSelect', multiSelectStr);
    aborted = isequal(dirpath, 0);
    if aborted
        kymoFilepaths = cell(0, 1);
    else
        kymoFilepaths = fullfile(dirpath, kymoFilenames);
    end
    if not(iscell(kymoFilepaths))
        kymoFilepaths = {kymoFilepaths};
    end
end