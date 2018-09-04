function [eldKymoAlignSettings] = load_eld_kymo_align_settings()
    settingsFilename = 'ELD_kymo_align.ini';

    import AppMgr.AppResourceMgr;
    settingsDirpath = AppResourceMgr.get_dirpath('SettingFiles');
    settingsIniFilepath = fullfile(settingsDirpath, settingsFilename);

    import FancyIO.ini2struct;
    eldKymoAlignSettings = ini2struct(settingsIniFilepath);
end