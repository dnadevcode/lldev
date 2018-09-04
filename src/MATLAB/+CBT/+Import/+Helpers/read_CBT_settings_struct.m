function fileParamsCBT = read_CBT_settings_struct(settingsIniFilepath)
    if nargin < 1
        import CBT.Import.Helpers.prompt_CBT_ini_filepath;
        settingsIniFilepath = prompt_CBT_ini_filepath();
    end

    if isempty(settingsIniFilepath)
        error('Settings file not provided');
    end
    import Fancy.IO.ini2struct;
    fileParamsCBT = ini2struct(settingsIniFilepath);
end