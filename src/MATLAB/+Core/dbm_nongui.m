
useGUI = 0;

import OldDBM.General.SettingsWrapper;
defaultSettingsFilepath = SettingsWrapper.get_default_newDBM_ini_filepath();
if not(exist(defaultSettingsFilepath, 'file'))
    defaultSettingsFilepath = '';
end
dbmOSW = SettingsWrapper.import_dbm_settings_from_ini(defaultSettingsFilepath);

dbmOSW.DBMSettingsstruct.dbmtool = 'hpfl-odm'; 
dbmOSW.DBMSettingsstruct.askForDBMtoolSettings = 0;

dbmOSW.DBMSettingsstruct.movies.askForMovies = 0;

dbmOSW.DBMSettingsstruct.detectlambdas = 0;
dbmOSW.DBMSettingsstruct.initialAngle = 0;
dbmOSW.DBMSettingsstruct.maxLambdaLen = inf;
dbmOSW.DBMSettingsstruct.angleStep = 0.01;
dbmOSW.DBMSettingsstruct.numPts = 100;
dbmOSW.DBMSettingsstruct.auto_run = 1;

% files = dir( );

filesC = arrayfun(@(x) fullfile(files(x).folder,files(x).name),1:length(files),'un',false);
% filesC = arrayfun(@(x) fullfile(files(x).folder,files(x).name),30:34,'un',false);

dbmOSW.DBMSettingsstruct.genome_assembly_pipeline = 0;
dbmOSW.DBMSettingsstruct.movies.movieNames = filesC;
dbmOSW.DBMSettingsstruct.averagingWindowWidth = 3;
% dbmOSW.DBMSettingsstruct.movies.movieNames = {filesC{1:3}};
dbmOSW.DBMSettingsstruct.npeaks = 2;
dbmOSW.DBMSettingsstruct.distbetweenChannels = 7;
% fd =fopen(dbmOSW.DBMSettingsstruct.movies.movieFile);
% filePh = fopen(dbmOSW.DBMSettingsstruct.movies.movieFile,'w');
% fprintf(filePh,'%s\n',filesC{:});
% fclose(filePh);
 
% DBM_Gui(useGUI,dbmOSW)
dna_barcode_matchmaker(0,dbmOSW);
 
import Core.hpfl_extract;
[dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(dbmOSW.DBMSettingsstruct);
 

%% czi to tif
% data = dir('dirname/*.czi');
% % 
% DBM4.convert_czi_to_tif(data,0);
%  
