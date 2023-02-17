
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

% files = dir('C:\Users\Lenovo\postdoc\DATA\Chromosome\Yeast_09_27_22\Example_tifs\Albertas\*.tif');
% files = dir('C:\Users\Lenovo\postdoc\MEETINGS\workgroup\workgroupdata\*.tif');
% files = dir('C:\Users\Lenovo\postdoc\MEETINGS\workgroup\test4\*.tif');
% files1 = dir('C:\Users\Lenovo\postdoc\DATA\LUISDATAMOV\2022-03-18\*.tif');
% files2 = dir('C:\Users\Lenovo\postdoc\DATA\LUISDATAMOV\2022-01-11\*.tif')
% files = [files1;files2]
% files = dir('C:\Users\Lenovo\git\dnadevcode\hpfl-odm\test\221007allP230sR1200ms-01_AcquisitionBlock2_pt2.7.tif');
% files = dir('C:\Users\Lenovo\git\dnadevcode\hpfl-odm\test\1234R1000ms-01-1_AcquisitionBlock2_pt2.6.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\LUISDATAMOV\2022-02-21\Experiment-5065.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\LUISDATAMOV\test\*.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\Mapping\testlong\*.tif');
files = dir('C:\Users\Lenovo\postdoc\DATA\Mapping\Radhika_kymos_22-11-08\OneDrive_1_11-17-2022\Movies\*.tif');
files = dir('C:\Users\Lenovo\postdoc\DATA\Mapping\Radhika_kymos_22-11-08\OneDrive_1_11-17-2022\lambda\*.tif');
files = dir('C:\Users\Lenovo\postdoc\DATA\Mapping\Radhika_kymos_22-11-08\OneDrive_2023-01-13\Multi tile TIFF files\series 1\1s1600ms-01_AcquisitionBlock2_pt2.15x1700y-8000.tif');
files = dir('/proj/snic2022-5-384/users/x_albdv/data/Yeast/mov/2022-03-18/*.tif')
% files  =dir('C:\Users\Lenovo\postdoc\DATA\Chromosome\ECOLIMOV\lambda\20220610_32087-4-st1_e.coli_filter-2_lambda-1.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\Chromosome\ECOLIMOV\*.tif');
% files=dir('C:\Users\Lenovo\postdoc\DATA\Chromosome\ECOLIMOV\lambda\*.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\Mapping\zhara\Lambda_Zara\Lambda_Zara\*.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\Mapping\zhara\czi\*.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\Chromosome\ECOLIMOV\*.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\Chromosome\czi files\czi files\*.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\Mapping_New_E.coli_all\Mapping_New_E.coli\New data_Jan 2023\2022-12-19\czi files\*.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\Mapping_New_E.coli_all\Mapping_New_E.coli\New data_Jan 2023\2022-12-20\1st experiment\czi files\20221220_87-st7_filter-2_int-35_mol-6.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\Mapping_New_E.coli_all\Mapping_New_E.coli\New data_Jan 2023\2022-12-20\1st experiment\czi files\20221220_87-st7_filter-2_int-35_mol-60.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\LUISDATAMOV\2022-03-18\*.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\LUISDATAMOV\2022-01-11\*.tif');

% files = dir('C:\Users\Lenovo\postdoc\DATA\LUISDATAMOV\2022-01-11\Experiment-3875.tif');


% files = dir('C:\Users\Lenovo\postdoc\DATA\Chromosome\czi files\czi files\20221219_87-st7_filter-2_int-35_mol-58-2.tif')
% files = dir('C:\Users\Lenovo\postdoc\DATA\Chromosome\czi files\czi files\*.tif');

% files = dir('C:\Users\Lenovo\git\test_2\*.tif');
% files = dir('C:\Users\Lenovo\postdoc\DATA\Mapping\Radhika_pep\fold\*.tif');
% files = dir('D:\Radhika\03-01-2023\data\*.tif');

% filesC = arrayfun(@(x) fullfile(files(x).folder,files(x).name),1:length(files),'un',false);
filesC = arrayfun(@(x) fullfile(files(x).folder,files(x).name),1:10,'un',false);

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
 
%% czi to tif
% data = dir('C:\Users\Lenovo\postdoc\DATA\Chromosome\Yeast_Luis_processed\220318\czi\*.czi');
% % 
% DBM4.convert_czi_to_tif(data,0);
%  