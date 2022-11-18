
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

dbmOSW.DBMSettingsstruct.detectlambdas = 1;

% files = dir('C:\Users\Lenovo\postdoc\DATA\Chromosome\Yeast_09_27_22\Example_tifs\Albertas\*.tif');
% files = dir('C:\Users\Lenovo\postdoc\MEETINGS\workgroup\workgroupdata\*.tif');
% files = dir('C:\Users\Lenovo\postdoc\MEETINGS\workgroup\test4\*.tif');
% files1 = dir('C:\Users\Lenovo\postdoc\DATA\LUISDATAMOV\2022-03-18\*.tif');
% files2 = dir('C:\Users\Lenovo\postdoc\DATA\LUISDATAMOV\2022-01-11\*.tif')
% files = [files1;files2]
% files = dir('C:\Users\Lenovo\git\dnadevcode\hpfl-odm\test\221007allP230sR1200ms-01_AcquisitionBlock2_pt2.7.tif');
files = dir('C:\Users\Lenovo\git\dnadevcode\hpfl-odm\test\1234R1000ms-01-1_AcquisitionBlock2_pt2.6.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\LUISDATAMOV\2022-02-21\Experiment-5061.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\LUISDATAMOV\test\*.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\Mapping\testlong\*.tif');
files = dir('C:\Users\Lenovo\postdoc\DATA\Mapping\Radhika_kymos_22-11-08\OneDrive_1_11-17-2022\Movies\allP230sR1200ms-01_AcquisitionBlock2_pt2.6.tif');

filesC = arrayfun(@(x) fullfile(files(x).folder,files(x).name),1:length(files),'un',false);
% filesC = arrayfun(@(x) fullfile(files(x).folder,files(x).name),3,'un',false);

dbmOSW.DBMSettingsstruct.movies.movieNames = filesC;
% fd =fopen(dbmOSW.DBMSettingsstruct.movies.movieFile);
% filePh = fopen(dbmOSW.DBMSettingsstruct.movies.movieFile,'w');
% fprintf(filePh,'%s\n',filesC{:});
% fclose(filePh);
 
% DBM_Gui(useGUI,dbmOSW)
dna_barcode_matchmaker(0,dbmOSW);
 
%% czi to tif
data = dir('C:\Users\Lenovo\postdoc\DATA\Mapping\Radhika_kymos_22-11-08\OneDrive_1_11-17-2022\czi file\*.czi');

DBM4.convert_czi_to_tif(data,0);
 