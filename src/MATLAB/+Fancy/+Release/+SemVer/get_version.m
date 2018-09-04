function [versionStr, majorVersion, minorVersion, patchVersion] = get_version(versionFilepath)
    % GET_VERSION Retrieves the version information from the version file
    %
    % Inputs:
    %   versionFilepath (optional; defaults to VERSION file in app dirpath)
    %     filepath to the version file (version file must be valid or it
    %     will throw an error. Valid files are formatted as
    %     "[major].[minor].[patch]" where "[major]", "[minor]", and
    %     "[patch]" are non-negative integers
    %
    % Outputs
    %   versionStr
    %      version as the string in the version file
    %   majorVersion
    %      the major version number
    %   minorVersion
    %      the minor version number
    %   patchVersion
    %      the patch version number
    %
    % Authors:
    %   Saair Quaderi
    
    if nargin < 1
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        versionFilepath = fullfile(appDirpath, 'VERSION');
    end
    if not(exist(versionFilepath, 'file'))
        error('VERSION file is missing!');
    end
    versionStr = fileread(versionFilepath);
    
    import Fancy.Release.SemVer.split_version_string;
    [majorVersion, minorVersion, patchVersion] = split_version_string(versionStr);
end

