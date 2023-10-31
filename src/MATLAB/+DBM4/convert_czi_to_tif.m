function [newNames, newInfo ] = convert_czi_to_tif(data, numChannels)
%   convert_czi_to_tif
%
%   Args:
%       data - files to convert. If empty, asks for folder to convert
%       multiChannels - whether data should be loaded as multichannel

%   Returns:
%       newNames - new names for data files
%       newInfo - new info for data files

%   Requirements:
%       bfconvert/bfmatlab should be in "DataCatche" folder, or
%       installed globally

%   Example:
%
%   Modified:
%       31/10/23

% First check if the selected tool (bfopen) is loaded:
mFilePath = mfilename('fullpath');
dataCatcheFold = fileparts(fileparts(fileparts(fileparts(mFilePath))));
bfmatloaded = exist('bfopen', 'file') == 2;


% download and un-zip bfmatlab
if bfmatloaded == 0  
    websave(fullfile(dataCatcheFold,'DataCache','bfmatlab.zip'),'https://downloads.openmicroscopy.org/bio-formats/7.0.1/artifacts/bfmatlab.zip');
    unzip(fullfile(dataCatcheFold,'DataCache','bfmatlab.zip'),fullfile(dataCatcheFold,'DataCache'));
    addpath(genpath(fullfile(dataCatcheFold,'DataCache')));
    bfmatloaded = exist('bfopen', 'file') == 2;
end

if bfmatloaded == 0
    error('Failed to load bfmatlab, please download https://downloads.openmicroscopy.org/bio-formats/7.0.1/artifacts/bfmatlab.zip and unzip to DataCache folder');
end

if nargin < 1 || isempty(data)
    data = dir(fullfile(uigetdir(),'*.czi'));
end


if nargin < 2 || isempty(numChannels)
    opts.Interpreter = 'tex';
    % Include the desired Default answer
    opts.Default = '1';
    % Use the TeX interpreter to format the question
    quest = 'How many channels in the data?';
    answer = questdlg(quest,'Number channels',...
              '1','2','3',opts)
    numChannels = str2num(answer);
end
 
newNames = cell(1,length(data));
newInfo = cell(1,length(data));

import DBM4.load_czi;
for i=1:length(data)
    disp(strcat(['Converting movie ' num2str(i) ' from ' num2str(length(data)) ]))
    filename = fullfile(data(i).folder,data(i).name);
    [channelImg,metadata] = load_czi(filename,0, numChannels);

    [fd,fm,fe] = fileparts(filename);
    nameNew = strrep(filename,fe,'');
    nameNew2 = strrep(filename,fe,'.ini');
    if exist(strcat(nameNew,'_CH1.tif'),'file')
        delete(strcat(nameNew,'_CH1.tif')); % in case already exists tif, remove 
    end
    if exist(strcat(nameNew,'_CH2.tif'),'file')
        delete(strcat(nameNew,'_CH2.tif')); % in case already exists tif, remove 
    end
    if exist(strcat(nameNew,'_CH3.tif'),'file')
        delete(strcat(nameNew,'_CH3.tif')); % in case already exists tif, remove 
    end
%     newInfo{i} = nameNew2;
    newNames{i} = strcat(nameNew,'_CH1.tif');
    newInfo{i} = nameNew2;

    for j=1:length(channelImg{1})
        switch numChannels
            case 1
                imwrite(  uint16(round(channelImg{1}{j})),strcat(nameNew,'_CH1.tif'),"WriteMode","append");
            case 2
                
                imwrite( uint16(round(channelImg{1}{j})),strcat(nameNew,'_CH1.tif'),"WriteMode","append");
                imwrite( uint16(round(channelImg{2}{j})),strcat(nameNew,'_CH2.tif'),"WriteMode","append");
            case 3
                imwrite( uint16(round(channelImg{1}{j})),strcat(nameNew,'_CH1.tif'),"WriteMode","append");
                imwrite( uint16(round(channelImg{2}{j})),strcat(nameNew,'_CH2.tif'),"WriteMode","append");
                imwrite( uint16(round(channelImg{3}{j})),strcat(nameNew,'_CH3.tif'),"WriteMode","append");
            otherwise
        end
    end

    metadataFile = fopen(nameNew2,'w');
    metadataKeys = metadata.keySet().iterator();
    for k=1:metadata.size()
      key = metadataKeys.nextElement();
      value = metadata.get(key);
      fprintf(metadataFile,'%s = %s\n', key, value);
    end
    fclose(metadataFile);



end
    disp(strcat(['Done converting']));

end
