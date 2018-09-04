function [shouldExportLowestRecursive, tsvFilepathRecursive] = prompt_should_export_lowest_o_vals_recursive(alphaRecursive, defaultTsvDirpath)   
    if nargin < 2
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        defaultTsvDirpath = appDirpath;
    end

    choiceExportLowestRecursivePrompt = sprintf('Output tsv of lowest o-values (recursive with alpha = %g)?', alphaRecursive);
    choiceExportLowestRecursive = menu(choiceExportLowestRecursivePrompt, 'Yes', 'No');
    shouldExportLowestRecursive = (choiceExportLowestRecursive == 1);
    tsvFilepathRecursive = '';
    if shouldExportLowestRecursive
        alphaSafeStr = strrep(num2str(alphaRecursive),'.', '_');
        timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
        defaultFilename = sprintf('recursive_alpha_%s_lowest_o-values_%s.tsv', alphaSafeStr, timestamp);
        defaultFilepath = fullfile(defaultTsvDirpath, defaultFilename);
        [tsvFilenameRecursive, tsvDipath, ~] = uiputfile('*.tsv', 'Save O-val (Rec) Data As', defaultFilepath);
        if isequal(tsvDipath, 0)
            shouldExportLowestRecursive = false;
        else
            tsvFilepathRecursive = fullfile(tsvDipath, tsvFilenameRecursive);
        end
    end
end