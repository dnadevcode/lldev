function [shouldExportLowestNonrecursive, tsvFilepathNonrecursive] = prompt_should_export_lowest_o_vals_nonrecursive(defaultTsvDirpath)   
    if nargin < 1
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        defaultTsvDirpath = appDirpath;
    end
    
    choiceExportLowestNonrecursivePrompt = 'Output tsv of lowest o-values (non-recursive)?';
    choiceExportLowestNonrecursive = menu(choiceExportLowestNonrecursivePrompt, 'Yes', 'No');
    shouldExportLowestNonrecursive = (choiceExportLowestNonrecursive == 1);
    tsvFilepathNonrecursive = '';
    if shouldExportLowestNonrecursive
        timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
        defaultFilename = sprintf('nonrecursive_lowest_o-values_%s.tsv', timestamp);
        defaultFilepath = fullfile(defaultTsvDirpath, defaultFilename);
        [tsvFilenameRecursive, tsvDipath, ~] = uiputfile('*.tsv', 'Save O-val (Nonrec) Data As', defaultFilepath);
        if isequal(tsvDipath, 0)
            shouldExportLowestNonrecursive = false;
        else
            tsvFilepathNonrecursive = fullfile(tsvDipath, tsvFilenameRecursive);
        end
    end
end