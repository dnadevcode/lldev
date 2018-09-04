function [aborted, movieFilepaths] = try_prompt_movie_filepaths(promptTitle, allowMultiselect, defaultFilepath)
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
            promptTitle = 'Select Movie tiff files';
        else
            promptTitle = 'Select Movie tiff file';
        end
    end
    if allowMultiselect
        multiSelectStr = 'on';
    else
        multiSelectStr = 'off';
    end
    filterSpec = {'*.tif;*.tiff;'};
    if isempty(defaultFilepath)
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        defaultFilepath = appDirpath;
    end

    [movieFilenames, dirpath] = uigetfile(filterSpec, promptTitle, pwd, 'MultiSelect', multiSelectStr);
    aborted = isequal(dirpath, 0);
    if aborted
        movieFilepaths = cell(0, 1);
    else
        movieFilepaths = fullfile(dirpath, movieFilenames);
    end
    if not(iscell(movieFilepaths))
        movieFilepaths = {movieFilepaths};
    end
end