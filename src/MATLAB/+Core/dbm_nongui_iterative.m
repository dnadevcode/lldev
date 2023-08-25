
useGUI = 0;

import DBM4.UI.find_default_settings_path;
defaultSettingsFilepath = find_default_settings_path('DBMnew.ini');

import Fancy.IO.ini2struct;
dbmOSW.DBMSettingsstruct = ini2struct(defaultSettingsFilepath);

dbmOSW.DBMSettingsstruct.dbmtool = 'hpfl-odm'; 
dbmOSW.DBMSettingsstruct.askForDBMtoolSettings = 0;

dbmOSW.DBMSettingsstruct.movies.askForMovies = 0;

dbmOSW.DBMSettingsstruct.detectlambdas = 0;
dbmOSW.DBMSettingsstruct.initialAngle = 0;
dbmOSW.DBMSettingsstruct.maxLambdaLen = inf;
dbmOSW.DBMSettingsstruct.angleStep = 0.01;
%
dbmOSW.DBMSettingsstruct.numPts = 100;
dbmOSW.DBMSettingsstruct.auto_run = 1;
dbmOSW.DBMSettingsstruct.SigmaLambdaDet = 4;

userDir = '/export/scratch/albertas/data_temp/folderwithfolders/';


% if no subfolders, run single folder
d = dir(userDir);
dfolders = d([d(:).isdir]);

dfolders = dfolders(~ismember({dfolders(:).name},{'.','..'}));


dbmOSW.DBMSettingsstruct.genome_assembly_pipeline = 0;
dbmOSW.DBMSettingsstruct.averagingWindowWidth = 3;
% dbmOSW.DBMSettingsstruct.movies.movieNames = {filesC{1:3}};
dbmOSW.DBMSettingsstruct.npeaks = 2;
dbmOSW.DBMSettingsstruct.distbetweenChannels = 7;
% fd =fopen(dbmOSW.DBMSettingsstruct.movies.movieFile);
% filePh = fopen(dbmOSW.DBMSettingsstruct.movies.movieFile,'w');
% fprintf(filePh,'%s\n',filesC{:});
% fclose(filePh);


for i=1:length(dfolders)
    userDir = fullfile(dfolders(i).folder,dfolders(i).name);
    files = [dir(fullfile(userDir,'*.tif')),dir(fullfile(userDir,'*.czi'))];

    
    filesC = arrayfun(@(x) fullfile(files(x).folder,files(x).name),1:length(files),'un',false);
% filesC = arrayfun(@(x) fullfile(files(x).folder,files(x).name),30:34,'un',false);
    dbmOSW.DBMSettingsstruct.movies.movieNames = filesC;

  
    import Core.hpfl_extract;
    [dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(dbmOSW.DBMSettingsstruct);

    % In case we want stuff loadable in DBM:
    DBMSettingsstruct = dbmOSW.DBMSettingsstruct;
    DBMMainstruct = dbmStruct;
    for j=1:length(DBMMainstruct.fileCells)
    DBMMainstruct.fileCells{j}.preCells = [];% save some space by not printing this
    end
    % always save session data as DBM loadable. kymoStructs possibly saved

    targetFolder = userDir;
%         [~,~] 
    % twice (also in dbmStruct)
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    save(fullfile(targetFolder,['dbm_session_data_',timestamp,'.mat']),'DBMMainstruct','DBMSettingsstruct');
    
    import DBM4.Export.export_raw_kymos;
     export_raw_kymos(dbmOSW,DBMMainstruct,timestamp);

end


%% czi to tif
% data = dir('dirname/*.czi');
% % 
% DBM4.convert_czi_to_tif(data,0);
%  
