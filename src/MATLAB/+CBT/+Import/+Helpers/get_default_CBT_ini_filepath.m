function [defaultCBTIniFilepath] = get_default_CBT_ini_filepath()
    defaultSettingsFilename = 'CBT.ini';

    import Fancy.AppMgr.AppResourceMgr;
    defaultSettingsDirpath = AppResourceMgr.get_dirpath('SettingFiles');
    defaultCBTIniFilepath = fullfile(defaultSettingsDirpath, defaultSettingsFilename);
end