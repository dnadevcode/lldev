function [defaultSettingsFilepath] = get_default_NCBI_ini_filepath()
    defaultSettingsFilename = 'NCBI.ini';
    import Fancy.AppMgr.AppResourceMgr;
    defaultSettingsDirpath = AppResourceMgr.get_dirpath('SettingFiles');
    defaultSettingsFilepath = fullfile(defaultSettingsDirpath, defaultSettingsFilename);
end