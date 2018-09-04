function [majorVersion, minorVersion, patchVersion] = split_version_string(versionStr)
    % SPLIT_VERSION_STRING
    %   Splits a version string into its three version components
    %
    % Inputs:
    %   versionStr 
    %     string containgin the version formatted as 
    %       "[major].[minor].[patch]"
    %     where "[major]", "[minor]" and "[patch]" are non-negative
    %     integers
    %     will throw an error if the string is not formatted correctly
    %     
    %
    % Outputs
    %   majorVersion
    %      the major version number
    %   minorVersion
    %      the minor version number
    %   patchVersion
    %      the patch version number
    %
    % Authors:
    %   Saair Quaderi
    
    invalidVersionMsg = 'Invalid version format!';
    splitVersion = strsplit(versionStr, '.');
    if length(splitVersion) ~= 3
        error(invalidVersionMsg);
    end
    splitVersion = cellfun(@(x) str2double(x), splitVersion);
    if any(isnan(splitVersion))
        error(invalidVersionMsg);
    end
    splitVersion = arrayfun(@uint16, splitVersion);
    splitVersion = arrayfun(@double, splitVersion);
    majorVersion = splitVersion(1);
    minorVersion = splitVersion(2);
    patchVersion = splitVersion(3);
    versionStrClean = sprintf('%d.%d.%d', majorVersion, minorVersion, patchVersion);
    if not(strcmp(versionStr, versionStrClean))
        error(invalidVersionMsg);
    end
end