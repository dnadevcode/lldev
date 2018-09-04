function gsI = import_grayscale_tiff_img(sourceDirpath)
    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    if nargin < 1
        sourceDirpath = [];
    end
    if isempty(sourceDirpath)
        sourceDirpath = appDirpath;
    end
    rgbI = zeros(0, 0, 1);
    validFileExts = '*.tif; *.tiff; *.TIF; .TIFF';
    [currSourceFilename, dirpath] = uigetfile(validFileExts, 'Select grayscale tiff', sourceDirpath);
    if all(dirpath == 0)
        return;
    end
    srcFilepath = fullfile(dirpath, currSourceFilename);
    fprintf('Importing ''%s''...\n', srcFilepath);
    gsI = imread(srcFilepath);
end