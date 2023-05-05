function [] = export_dbm_session_struct_mat(dbmODW, dbmOSW, outputFilepath)
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    outputMatFilename = sprintf('session_%s.mat', timestamp);

    [~,~] = mkdir(outputFilepath);
%     outputFilepath = fullfile(defaultOutputDirpath, defaultOutputFilename);
%     [outputMatFilename, outputDirpath] = uiputfile('*.mat', 'Save Session', defaultOutputFilepath);
%     if isequal(outputDirpath, 0)
%         return;
%     end
    outputFilepath = fullfile(outputFilepath, outputMatFilename);
    DBMMainstruct = dbmODW.DBMMainstruct; %#ok<NASGU>
    DBMSettingsstruct = dbmOSW.DBMSettingsstruct; %#ok<NASGU>
    save(outputFilepath, 'DBMMainstruct', 'DBMSettingsstruct');
end