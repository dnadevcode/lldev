function dngFilepaths = prompt_dng_filepaths(sourcePath, multiselectOnTF)
    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    if nargin < 1
        sourcePath = [];
    end
    if nargin < 2
        multiselectOnTF = false;
    end


    if isempty(sourcePath)
        sourcePath = appDirpath;
    end

    validFileExts = '*.dng; *.DNG';
    if multiselectOnTF
        [dngFilename, dirpath] = uigetfile(validFileExts, 'Select bayer dngs', sourcePath, 'MultiSelect', 'on');
    else
        [dngFilename, dirpath] = uigetfile(validFileExts, 'Select bayer dng', sourcePath);
    end
    if dirpath == 0
        dngFilepaths = [];
        return;
    end
    dngFilepaths = fullfile(dirpath, dngFilename);
end