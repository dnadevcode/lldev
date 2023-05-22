function [defaultSettingsFilepath] = find_default_settings_path(fileName)
    % locate sessions file in the root dir
    
    mFilePath = mfilename('fullpath');
    mfolders = split(mFilePath, {'\', '/'});
    defaultSettingsFilepath = fullfile(mfolders{1:end-5},'SettingFiles',fileName);


end

