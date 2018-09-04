function [defaultTxtFilepathPeaks] = get_default_peaks_txt_filepath(defaultTxtDirpath, filenamePrefix)
    defaultTxtFilenamePeaks = sprintf('%s_Peaks.txt', filenamePrefix);
    defaultTxtFilepathPeaks = fullfile(defaultTxtDirpath, defaultTxtFilenamePeaks);
end