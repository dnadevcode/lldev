function [defaultSettingsFilepath] = get_default_cam_ini_filepath()
    defaultSettingsFilename = '';
    import Fancy.AppMgr.AppResourceMgr;
    defaultSettingsDirpath = AppResourceMgr.get_dirpath('SettingFiles');
    defaultSettingsFilepath = fullfile(defaultSettingsDirpath, defaultSettingsFilename);
end