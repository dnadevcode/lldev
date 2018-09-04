function [shouldSaveGumbelCurveTsv, tsvFilepath] = prompt_should_export_gumble_curve_as_tsv(plotTitle, defaultFilepath)
    if nargin < 1
        choiceSaveGumbelCurvePrompt = 'Output tsv of gumbel curve';
        timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        defaultTsvDirpath = appDirpath;
        defaultFilename = sprintf('gumbelCurve_%s.tsv', timestamp);
        defaultFilepath = fullfile(defaultTsvDirpath, defaultFilename);
    else
        if nargin < 2
            timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
            import Fancy.AppMgr.AppResourceMgr;
            appRsrcMgr = AppResourceMgr.get_instance();
            appDirpath = appRsrcMgr.get_app_dirpath();
            defaultTsvDirpath = appDirpath;
            defaultFilename = sprintf('gumbelCurve_%s_%s.tsv', plotTitle, timestamp);
            defaultFilepath = fullfile(defaultTsvDirpath, defaultFilename);
        end
        choiceSaveGumbelCurvePrompt = sprintf('Output tsv of gumbel curve from ''%s''?', plotTitle);
    end
    
    choiceSaveGumbelCurve = menu(choiceSaveGumbelCurvePrompt, 'Yes', 'No');
    shouldSaveGumbelCurveTsv = (choiceSaveGumbelCurve == 1);
    tsvFilepath = '';
    if shouldSaveGumbelCurveTsv
        [tsvFilename, tsvDipath, ~] = uiputfile('*.tsv', 'Save Gumbel Curve Data As', defaultFilepath);
        if isequal(tsvDipath, 0)
            shouldSaveGumbelCurveTsv = false;
        else
            tsvFilepath = fullfile(tsvDipath, tsvFilename);
        end
    end
end