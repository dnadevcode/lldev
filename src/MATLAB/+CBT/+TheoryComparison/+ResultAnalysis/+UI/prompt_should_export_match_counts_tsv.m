function [shouldExportMatchCounts, tsvFilepath] = prompt_should_export_match_counts_tsv(isRecursive, alpha)
    tsvFilepath = '';
    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    tsvDefaultDipath = appDirpath;
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    defaultFilename = sprintf('match_counts_%s.tsv', timestamp);
    if isRecursive
        alphaSafeStr = strrep(num2str(alpha),'.','_');
        menuText = sprintf('Output tsv of match counts (Recursive with alpha = %g)?', alpha);
        defaultFilename = sprintf('recursive_alpha_%s_%s', alphaSafeStr, defaultFilename);
        putFileTitle = 'Save Match Counts (Recursive) As';
    else
        menuText = 'Output tsv of match counts (Non-recursive)?';
        defaultFilename = sprintf('nonrecursive_%s', defaultFilename);
        putFileTitle = 'Save Match Counts (Non-recursive) As';
    end
    choiceExportMatchCounts = menu(menuText, 'Yes', 'No');
    shouldExportMatchCounts = (choiceExportMatchCounts == 1);
    if shouldExportMatchCounts
        defaultFilepath = fullfile(tsvDefaultDipath, defaultFilename);
        [tsvFilename, tsvDipath, ~] = uiputfile('*.tsv', putFileTitle, defaultFilepath);
        if isequal(tsvDipath, 0)
            shouldExportMatchCounts = false;
        else
            tsvFilepath = fullfile(tsvDipath, tsvFilename);
        end
    end
end