function [shouldExportMatchesRecursive, tsvFilepathRecursive] = prompt_should_export_matches_recursive(alpha, defaultDirpath)
    if nargin < 2
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        defaultDirpath = appDirpath;
    end
    choiceExportMatchesRecursivePrompt = sprintf('Output tsv of matches (Recursive with alpha = %g)?', alpha);
    choiceExportMatchesRecursive = menu(choiceExportMatchesRecursivePrompt, 'Yes', 'No');
    shouldExportMatchesRecursive = (choiceExportMatchesRecursive == 1);
    tsvFilepathRecursive = '';
    if shouldExportMatchesRecursive
        alphaSafeStr = strrep(num2str(alpha), '.', '_');
        timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
        defaultFilename = sprintf('recursive_alpha_%s_matches_%s.tsv', alphaSafeStr, timestamp);
        defaultFilepath = fullfile(defaultDirpath, defaultFilename);
        [tsvFilenameMatchRecursive, tsvDirpath, ~] = uiputfile('*.tsv', 'Save O-val (Nonrec) Data As', defaultFilepath);
        if isequal(tsvDirpath, 0)
            shouldExportMatchesRecursive= false;
        else
            tsvFilepathRecursive = fullfile(tsvDirpath, tsvFilenameMatchRecursive);
        end
    end
end