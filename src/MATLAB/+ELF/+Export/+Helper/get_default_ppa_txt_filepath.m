function [defaultTxtFilepathPPA] = get_default_ppa_txt_filepath(defaultTxtDirpath, filenamePrefix)
    defaultTxtFilenamePPA = sprintf('%s_PeaksPosAndArea.txt', filenamePrefix);
    defaultTxtFilepathPPA = fullfile(defaultTxtDirpath, defaultTxtFilenamePPA);
end