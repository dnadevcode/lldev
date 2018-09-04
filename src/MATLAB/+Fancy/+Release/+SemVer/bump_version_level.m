function [newVersionStr, newMajorVersion, newMinorVersion, newPatchVersion] = bump_version_level(oldVersionStr, versionLevelToBump)
    % BUMP_VERSION_LEVEL - takes in an old version string and bumps
    %   either the major, minor, or patch version
    %   (version level specified is incremented and lower version levels,
    %    are reset to 0)
    %
    % Inputs:
    %   oldVersionStr
    %     the old version string
    %   versionLevelToBump
    %     'major', 'minor', or 'patch' (version level to be bumped)
    %     (can also specify as 1, 2, or 3 for major, minor, or patch
    %     respectively)
    %
    % Outputs
    %   newVersionStr
    %     the new bumped version string
    %   newMajorVersion
    %     the new major version
    %   newMinorVersion
    %     the new minor version
    %   newPatchVersion
    %     the new patch version
    %
    % Authors:
    %   Saair Quaderi
    
    if isequal(versionLevelToBump, 1)
        versionLevelToBump = 'major';
    elseif isequal(versionLevelToBump, 2)
        versionLevelToBump = 'minor';
    elseif isequal(versionLevelToBump, 3)
        versionLevelToBump = 'patch';
    end
    
    
    import Fancy.Release.SemVer.split_version_string;
    [newMajorVersion, newMinorVersion, newPatchVersion] = split_version_string(oldVersionStr);
    switch versionLevelToBump
        case 'major'
            newMajorVersion = newMajorVersion + 1;
            newMinorVersion = 0;
            newPatchVersion = 0;
        case 'minor'
            newMinorVersion = newMinorVersion + 1;
            newPatchVersion = 0;
        case 'patch'
            newPatchVersion = newPatchVersion + 1;
        otherwise
            error('Invalid version level to bump');
    end
    newVersionStr = sprintf('%d.%d.%d', newMajorVersion, newMinorVersion, newPatchVersion);
end