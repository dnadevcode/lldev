function [ncbiParamsIniFilepath] = prompt_NCBI_ini_filepath(defaultSettingsFilepath)
    if nargin < 1
        import NCBI.get_default_NCBI_ini_filepath;
        defaultSettingsFilepath = get_default_NCBI_ini_filepath();
    end

    [settingsFilename, settingsDirpath] = uigetfile('*.ini', 'Select NCBI Settings Ini File', defaultSettingsFilepath);
    if isequal(settingsDirpath, 0)
        ncbiParamsIniFilepath = [];
        return;
    end
    ncbiParamsIniFilepath = fullfile(settingsDirpath, settingsFilename);
end