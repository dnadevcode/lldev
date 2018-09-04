function [shouldExportMeanAndStd, tsvFilepathMeanAndStd] = prompt_should_export_mean_and_std(defaultDirpath)
    if nargin < 1
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        defaultDirpath = appDirpath;
    end
    choiceExportMeanAndStd = menu('Output std/mean?', 'Yes', 'No');
    shouldExportMeanAndStd = (choiceExportMeanAndStd == 1);
    tsvFilepathMeanAndStd = '';
    if shouldExportMeanAndStd
        timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
        defaultFilename = sprintf('std_and_mean_%s.tsv', timestamp);
        defaultFilepath = fullfile(defaultDirpath, defaultFilename);
        [tsvFilenameMeanAndStd, tsvDipath, ~] = uiputfile('*.tsv', 'Save Std & Mean Data As', defaultFilepath);
        if isequal(tsvDipath, 0)
            shouldExportMeanAndStd = false;
        else
            tsvFilepathMeanAndStd = fullfile(tsvDipath, tsvFilenameMeanAndStd);
        end
    end
end