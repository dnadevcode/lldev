function [aborted, experimentCurveNames, experimentCurveStructs] = get_experiment_curves_from_DBM_session()
    % get_experiment_curves_from_DBM_session - get experiment curves
    %   extracted from formatted DBM session .mat files provided
    %   by a prompt to the user

    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    defaulSessionsDirpath = fullfile(appDirpath, 'OutputFiles', 'Sessions');
    [dbmSessionFilename, dbmSessionDirpath] = uigetfile({'*.mat;'}, 'Select DBM Session File for Exp Data Import', defaulSessionsDirpath);
    aborted = isequal(dbmSessionDirpath, 0);
    if aborted
        experimentCurveNames = cell(0, 1);
        experimentCurveStructs = cell(0, 1);
        return;
    end
    sessionFilepath = fullfile(dbmSessionDirpath, dbmSessionFilename);


    import OldDBM.General.Import.try_loading_from_session_file;
    [dbmODW, dbmOSW] = try_loading_from_session_file(sessionFilepath);

    % TODO: add experiment viewing code downstream
    %   (something like OldDBM.General.UI.show_home_screen ?)
    
    import OldDBM.General.Export.DataExporter;
    dbmDE = DataExporter(dbmODW, dbmOSW);

    experimentCurveStructs = dbmDE.extract_experimental_structs();
    experimentCurveNames = cellfun(@(experimentCurveStruct) experimentCurveStruct.displayName, experimentCurveStructs, 'UniformOutput', false);
    aborted = false;
end