function [channelImg, metadata] = load_czi(filename,max_number_of_frames, channels)

    if nargin < 2 || isempty(max_number_of_frames);
        max_number_of_frames = 0;
    end

    if nargin < 3||isempty(channels)
        channels = 0;
    end
    % check if bfmatlab exists / maybe outside this function
    bfmatloaded = exist('bfopen', 'file') == 2;
    % download and un-zip bfmatlab
    if bfmatloaded == 0  
        dataCatcheFold = fileparts(fileparts(fileparts(fileparts(mFilePath))));
        websave(fullfile(dataCatcheFold,'DataCache','bfmatlab.zip'),'https://downloads.openmicroscopy.org/bio-formats/7.0.1/artifacts/bfmatlab.zip');
        unzip(fullfile(dataCatcheFold,'DataCache','bfmatlab.zip'),fullfile(dataCatcheFold,'DataCache'));
        addpath(genpath(fullfile(dataCatcheFold,'DataCache')));
        bfmatloaded = exist('bfopen', 'file') == 2;
    end
    if bfmatloaded == 0
        error('Failed to load bfmatlab, please download https://downloads.openmicroscopy.org/bio-formats/7.0.1/artifacts/bfmatlab.zip and unzip to DataCache folder');
    end

    channelImg = [];
    names = [];
    T = evalc(['data = bfopen(''', filename, ''');']);  % possible inconvenience: loads all data.


    numFrames = size(data{1,1},1)/channels;
    if max_number_of_frames~=0
        numFrames = min(numFrames,max_number_of_frames);
    end
        
    channelImg = cell(1,channels); % for now just sigle channel

    for j=1:channels
        for i=1:numFrames 
            channelImg{j}{i} = double(data{1,1}{j+channels*(i-1),1});
        end
    end

    metadata = data{1, 2};


end

