function [shouldExportMatchesNonrecursive, tsvFilepathNonrecursive] = prompt_should_export_matches_nonrecursive(defaultDirpath)
    if nargin < 1
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        defaultDirpath = appDirpath;
    end
    choiceExportMatchesNonrecursive = menu('Output tsv of matches (non-recursive)?', 'Yes', 'No');
    shouldExportMatchesNonrecursive = (choiceExportMatchesNonrecursive == 1);
    tsvFilepathNonrecursive = '';
    if shouldExportMatchesNonrecursive
        timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
        defaultFilename = sprintf('nonrecursive_matches_%s.tsv', timestamp);
        defaultFilepath = fullfile(defaultDirpath, defaultFilename);
        [tsvFilenameMatchNonrecursive, tsvDirpath, ~] = uiputfile('*.tsv', 'Save O-val (Nonrec) Data As', defaultFilepath);
        if not(isequal(tsvDirpath, 0))
            tsvFilepathNonrecursive = fullfile(tsvDirpath, tsvFilenameMatchNonrecursive);
        end
    end
end