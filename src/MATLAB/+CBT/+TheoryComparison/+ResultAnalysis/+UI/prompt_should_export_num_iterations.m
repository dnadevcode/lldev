function [shouldExportIterationsRecursive, tsvFilepathIterationsRecursive] = prompt_should_export_num_iterations(alpha, defaultDirpath)
    if nargin < 2
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        defaultDirpath = appDirpath;
    end
    choiceExportIterationsRecursivePrompt = sprintf('Output number of iterations with alpha = %g?', alpha);
    choiceExportIterationsRecursive = menu(choiceExportIterationsRecursivePrompt, 'Yes', 'No');
    shouldExportIterationsRecursive = (choiceExportIterationsRecursive == 1);
    tsvFilepathIterationsRecursive = '';
    if shouldExportIterationsRecursive
        alphaSafeStr = strrep(num2str(alpha), '.', '_');
        timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
        defaultFilename = sprintf('recursive_alpha_%s_iterations_%s.tsv', alphaSafeStr, timestamp);
        defaultFilepath = fullfile(defaultDirpath, defaultFilename);
        [tsvFilenameIterationsRecursive, tsvDipath] = uiputfile('*.tsv', 'Save Iterations Data As', defaultFilepath);
        if isequal(tsvDipath, 0)
            shouldExportIterationsRecursive = false;
        else
            tsvFilepathIterationsRecursive = fullfile(tsvDipath, tsvFilenameIterationsRecursive);
        end
    end
end