function rgbI = import_rgb_tiff_img(sourceDirpath, bayerPattern)
    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    if nargin < 1
        sourceDirpath = [];
    end
    if nargin < 2
        bayerPattern = 'bggr';
    end

    if isempty(sourceDirpath)
        sourceDirpath = appDirpath;
    end
    rgbI = zeros(0, 0, 3);
    validFileExts = '*.tif; *.tiff; *.TIF; .TIFF';
    [currSourceFilename, dirpath] = uigetfile(validFileExts, sprintf('Select %s-bayer tiff', bayerPattern), sourceDirpath);
    if all(dirpath == 0)
        return;
    end
    srcFilepath = fullfile(dirpath, currSourceFilename);
    fprintf('Importing ''%s''...\n', srcFilepath);
    bayerI = imread(srcFilepath);
    fprintf('Demosaicing image...\n');
    rgbI = demosaic(bayerI, bayerPattern);
end