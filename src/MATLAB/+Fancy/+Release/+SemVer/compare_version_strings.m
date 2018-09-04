function [versionDiff, versionDiffLevel] = compare_version_strings(versionStrA, versionStrB)
    % COMPARE_VERSION_STRINGS - compares two version strings
    %
    % Inputs
    %   versionStrA
    %     the first version string
    %   versionStrB
    %     the second version string
    %
    % Outputs
    %    relativeVal
    %      relative difference in version numbers at the first version
    %      level where there is a difference, or 0 if versions are the same
    %      (version level order is major, minor, patch)
    %      positive means that string B has greater version
    %      negative means that string A has greater version
    %      zero means that the versions are the same
    %    versionDiffLevel
    %      1 if there is a difference at the major version
    %      2 if there is no difference at the major version but a
    %           difference at the minor version
    %      3 if there is no difference at the major version
    %           and there is no difference at the minor version but a
    %           difference at the minor version
    %      NaN if there is no difference
    %
    % Authors:
    %   Saair Quaderi


    import Fancy.Release.SemVer.split_version_string;
    [majorVersionA, minorVersionA, patchVersionA] = split_version_string(versionStrA);
    [majorVersionB, minorVersionB, patchVersionB] = split_version_string(versionStrB);
    versionDiff = majorVersionB - majorVersionA;
    if versionDiff == 0
        versionDiff = minorVersionB - minorVersionA;
        if versionDiff == 0
            versionDiff = patchVersionB - patchVersionA;
            if versionDiff == 0
                versionDiffLevel = NaN;
            else
                versionDiffLevel = 3;
            end
        else
            versionDiffLevel = 2;
        end
    else
        versionDiffLevel = 1;
    end
end