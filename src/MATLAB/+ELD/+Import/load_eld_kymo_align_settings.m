function [eldKymoAlignSettings] = load_eld_kymo_align_settings()
%     settingsFilename = 'ELD.ini';
% 
%     import AppMgr.AppResourceMgr;
%     settingsDirpath = AppResourceMgr.get_dirpath('SettingFiles');
%     settingsIniFilepath = fullfile(settingsDirpath, settingsFilename);
% % 
% %     import FancyIO.ini2struct;
%         import MMT.FancyIO.ini2struct;
%     eldKymoAlignSettings = ini2struct(settingsIniFilepath);
    
    [kymoFilenames, dirpath] = uigetfile('*.ini', 'Select appropriate ini-file', 'Multiselect', 'off');
    aborted = isequal(dirpath, 0);
    if aborted
        return;
    end

    settingsIniFilepath = fullfile(dirpath, kymoFilenames);
    import MMT.FancyIO.ini2struct;
    eldKymoAlignSettings = ini2struct(settingsIniFilepath);
end