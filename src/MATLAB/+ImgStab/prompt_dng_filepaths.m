function dngFilepaths = prompt_dng_filepaths(sourcePath, multiselectOnTF)
    appDirpath = pwd();
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
        [dngFilenames, dirpath] = uigetfile(validFileExts, 'Select dngs', sourcePath, 'MultiSelect', 'on');
    else
        [dngFilenames, dirpath] = uigetfile(validFileExts, 'Select dng', sourcePath);
    end
    if dirpath == 0
        dngFilepaths = [];
        return;
    end
    dngFilepaths = fullfile(dirpath, dngFilenames);
    if multiselectOnTF && not(iscell(dngFilepaths))
        dngFilepaths = {dngFilepaths};
    end
end