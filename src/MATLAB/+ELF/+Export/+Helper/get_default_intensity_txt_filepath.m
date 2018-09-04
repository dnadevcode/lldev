function [defaultTxtFilepathFit] = get_default_intensity_txt_filepath(defaultTxtDirpath, filenamePrefix)
    defaultTxtFilenameFit = sprintf('%s.txt', filenamePrefix);
    defaultTxtFilepathFit = fullfile(defaultTxtDirpath, defaultTxtFilenameFit);
end