function [settingsIniFilepath] = prompt_CBT_ini_filepath(defaultCBTIniFilepath)
    if nargin < 1
        import CBT.Import.Helpers.get_default_CBT_ini_filepath;
        defaultCBTIniFilepath = get_default_CBT_ini_filepath();
    end
    [settingsFilename, settingsDirpath] = uigetfile('*.ini', 'Select CBT Settings Ini File', defaultCBTIniFilepath);
    if isequal(settingsDirpath, 0)
        settingsIniFilepath = '';
        return;
    end
    settingsIniFilepath = fullfile(settingsDirpath, settingsFilename);
end