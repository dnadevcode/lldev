function [camParamsIniFilepath] = prompt_cam_ini_filepath(defaultSettingsFilepath)
    if nargin < 1
        import Microscopy.Import.get_default_cam_ini_filepath;
        defaultSettingsFilepath = get_default_cam_ini_filepath();
    end

    [settingsFilename, settingsDirpath] = uigetfile('*.ini', 'Select Cam Settings Ini File', defaultSettingsFilepath);
    if isequal(settingsDirpath, 0)
        camParamsIniFilepath = [];
        return;
    end
    camParamsIniFilepath = fullfile(settingsDirpath, settingsFilename);
end