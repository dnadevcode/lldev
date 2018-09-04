function [] = prompt_version_update()
    % PROMPT_VERSION_UPDATE
    %  Prompts an update for the VERSION file through console prompts
    %
    % Side Effects:
    %  Potentially alters the version number in the VERSION file
    %
    % Authors:
    %   Saair Quaderi
    
    import Fancy.Release.SemVer.get_version;
    oldVersionStr = get_version();
    
    import Fancy.UI.FancyInput.ConsoleMenuPrompt;
    cmp = ConsoleMenuPrompt();
    cmp.set_prompt_text(sprintf('The current version is %s. What would you like to do?\n', oldVersionStr));
    cmp.add_option('Nothing', @() disp(''));
    cmp.add_option('Bump the major version (e.g. there was a breaking change)', @() continue_version_update_attempt(oldVersionStr, 'major'));
    cmp.add_option('Bump the minor version (e.g. there were no breaking changes, but new features were added)', @() continue_version_update_attempt(oldVersionStr, 'minor'));
    cmp.add_option('Bump the patch version (e.g. an unintended bug was fixed)', @() continue_version_update_attempt(oldVersionStr, 'patch'));
    cmp.add_option('Set the new version manually', @() continue_version_update_attempt(oldVersionStr, '', true));
    cmp.run_prompt()
    
    
    function continue_version_update_attempt(oldVersionStr, versionLevelToBump, manualVersionEntryTF)
        if nargin < 3
            manualVersionEntryTF = false;
        end
        if not(isempty(versionLevelToBump))
            import Fancy.Release.SemVer.bump_version_level;
            newVersionStr = bump_version_level(oldVersionStr, versionLevelToBump);
        elseif manualVersionEntryTF
            newVersionStr = input('Please enter the new version string: ', 's');
            newVersionStr = strtrim(newVersionStr);
            try
                import Fancy.Release.SemVer.split_version_string;
                [newMajorVersion, newMinorVersion, newPatchVersion] = split_version_string(newVersionStr);
            catch
               error('An invalid version string was entered');
            end
        else
            return;
        end
        
        import Fancy.Release.SemVer.compare_version_strings;
        [versionDiff, versionDiffLevel] = compare_version_strings(oldVersionStr, newVersionStr);
        if versionDiff == 0
            return;
        end
        if versionDiff < 0
            warning('The specified new version (%s) is further back than the current version (%s). This is usually a mistake!', newVersionStr, oldVersionStr);
        end

        import Fancy.UI.FancyInput.ConsoleMenuPrompt;
        cmp2 = ConsoleMenuPrompt();
        cmp2.set_prompt_text(sprintf('Are you sure you want to change the version from %s to %s?\n', oldVersionStr, newVersionStr));
        cmp2.add_option('Yes', @() actually_attempt_version_change(newVersionStr));
        cmp2.add_option('No', @() sprintf('Version left at %s\n', oldVersionStr));
        cmp2.run_prompt();
        
        function actually_attempt_version_change(newVersionStr)
            import Fancy.Release.SemVer.set_version;
            set_version(newVersionStr);

            import Fancy.Release.SemVer.get_version;
            newVersionStr2 = get_version();
            
            if not(strcmp(newVersionStr2, newVersionStr))
                fprintf('Failed to update version number to %s\n', newVersionStr);
            else
                fprintf('Successfully updated version number to %s\n', newVersionStr); 
            end
            
        end
    end
    
end