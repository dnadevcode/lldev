% pre-process saphyr images to be loadable to DBM
% (Albertas) most analysis is in my hpflproject\test\saphyr folder 

saphyrFold = 'D:\Metagenomic run\'; % choose saphyr folder

import DBM4.GenomAs.run_genome_assembly_pipeline;
import DBM4.Saphyr.load_dark_frame_means;
import DBM4.Saphyr.load_save_img;
import DBM4.Saphyr.file_list;

% dark-frames
fullfiles = file_list(saphyrFold);

import DBM4.UI.find_default_settings_path;
defaultSettingsFilepath = find_default_settings_path('DBMnew.ini');
import Fancy.IO.ini2struct;
dbmOSW.DBMSettingsstruct = ini2struct(defaultSettingsFilepath);

% some specific settings
dbmOSW.DBMSettingsstruct.nmPerPixel = 110; % nmpx saphyr?
dbmOSW.DBMSettingsstruct.minLen = 150; % min length
dbmOSW.DBMSettingsstruct.minOverlap = 150;
dbmOSW.DBMSettingsstruct.channels = 2;
dbmOSW.DBMSettingsstruct.savefullsession = 1; % saves session loadable in DBM


% for test, take specific run/scan/bank % if test:
runid = 2;
scanid = 1;
bangIds = 1; % can be 1-4
molIds = 1; %(1:length(fullfiles.run(runid).scan(scanid).bank(bankid).ch{1}))
%% run
totKm=[];
numR = 1;
out = cell(1,numR);
barAll = [];
for bankid=1:bangIds
    
    % darkframe - estimate of the background.
    [meanBgrounds,bgStruct] = load_dark_frame_means(fullfiles.run(runid).scan(scanid).bank(bankid).bg);

    for  idx = molIds
        % load imiages and save as mat in "matfilesrun"
        filename = load_save_img(fullfiles.run(runid).scan(scanid).bank(bankid).ch,idx,meanBgrounds);
        [barcodeGen,barGenMerged,kymoStructs] = run_genome_assembly_pipeline('matfilestorun', dbmOSW);
        barAll = [ barAll barcodeGen];
    end
end

%          [channelImg,imageData] 
