function [] = set_version(newVersionStr, versionFilepath)
    % SET_VERSION Sets the version string to the version file
    %
    % Inputs:
    %   newVersionStr
    %      new version string to set inside the file
    %        version string must be valid or it
    %        will throw an error. Valid versions are formatted as
    %        "[major].[minor].[patch]" where "[major]", "[minor]", and
    %        "[patch]" are non-negative integers
    %   versionFilepath (optional; defaults to VERSION file in app dirpath)
    %     filepath to the version file
    %
    % Side Effects:
    %   Updates the version file with the specified version
    %
    % Authors:
    %   Saair Quaderi
    
    if nargin < 2
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        versionFilepath = fullfile(appDirpath, 'VERSION');
    end
    
    import Fancy.Release.SemVer.split_version_string;
    [newMajorVersion, newMinorVersion, newPatchVersion] = split_version_string(newVersionStr);
    fileID = fopen(versionFilepath, 'w');
    fprintf(fileID,'%d.%d.%d', newMajorVersion, newMinorVersion, newPatchVersion);
    fclose(fileID);
end