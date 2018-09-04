function meltmapConnSettings = load_meltmap_conn_settings()
    import Fancy.IO.ini2struct;
    defaultSettingsFilename = 'MeltmapPostgreSQL.ini';
    meltmapConnSectionName = 'meltmapPostgresSQL';

    import Fancy.AppMgr.AppResourceMgr;
    defaultSettingsDirpath = AppResourceMgr.get_dirpath('SettingFiles');
    defaultSettingsFilepath = fullfile(defaultSettingsDirpath, defaultSettingsFilename);

    [settingsFilename, settingsDirpath] = uigetfile('*.ini','Select ELF Settings Ini File', defaultSettingsFilepath);
    if isequal(settingsDirpath, 0)
        meltmapConnSettings = [];
        return;
    end
    settingsIniFilepath = fullfile(settingsDirpath, settingsFilename);

    meltmapConnSettings = ini2struct(settingsIniFilepath);

    if not(isfield(meltmapConnSettings, meltmapConnSectionName))
        warning('Could not find ELF param secion name (''%s'') in ini file\n', meltmapConnSectionName);
        return;
    end

    meltmapConnSettings = meltmapConnSettings.(meltmapConnSectionName);
end
