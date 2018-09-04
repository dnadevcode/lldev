function [aborted, srcTiffFilepaths] = try_prompt_movie_filepaths(promptTitle, multiselectOn, defaultFilepath)
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
            promptTitle = 'Select Movie Tiff Files';
        else
            promptTitle = 'Select Movie Tiff File';
        end
    end
    if multiselectOn
        multiselectStr = 'on';
    else
        multiselectStr = 'off';
    end
    srcTiffFilepaths = cell(0, 1);

    [srcTiffFilenames, dirpath] = uigetfile({'*.tif;'}, promptTitle, defaultFilepath, 'MultiSelect', multiselectStr);

    aborted = isequal(dirpath, 0);
    if aborted
        return;
    end
    if not(iscell(srcTiffFilenames))
        srcTiffFilenames = {srcTiffFilenames};
    end
    srcTiffFilepaths = fullfile(dirpath, srcTiffFilenames(:));
end