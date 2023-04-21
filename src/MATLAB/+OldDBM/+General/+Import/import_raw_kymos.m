function [rawKymos, rawKymoFilepaths,rawBitmasks,enhanced] = import_raw_kymos(defaultRawKymoDirpath)
    % IMPORT_RAW_KYMOS - here the user can import data straight from kymographs 
    %	(assumed unaligned), rather than from tif files (importing from tif 
    %	files is handled in importdata() above).
    % 
    % Authors:
    %   Charleston Noble
    %   Tobias Ambjörnsson
    if nargin < 1
        defaultRawKymoDirpath = pwd();
    end
    
    
    % Get the files

    [rawKymoFilenames, rawKymoDirpath] = uigetfile(...
        {'*.tif;'}, ...
        'Select raw kymo file(s) to import', ...
        defaultRawKymoDirpath, ...
        'MultiSelect','on');

    if isequal(rawKymoDirpath, 0)
        rawKymos = cell(0,1);
        rawKymoFilepaths = cell(0, 1);
        rawBitmasks =  cell(0, 1);
        enhanced =  cell(0, 1);

        return;
    end

    if not(iscell(rawKymoFilenames))
        rawKymoFilenames = {rawKymoFilenames};
    end
    rawKymoFilenames = rawKymoFilenames(:);
    rawKymoFilepaths = fullfile(rawKymoDirpath, rawKymoFilenames);
    numFiles = length(rawKymoFilepaths);



    % Go through each of the files.
    if numFiles > 0
        fprintf('Importing data from:\n');
    end
    
    rawKymos = cell(numFiles, 1);
    rawBitmasks = cell(numFiles, 1);
    enhanced =  cell(numFiles, 1);
    for fileNum = 1:numFiles
        rawKymoFilename = rawKymoFilenames{fileNum};
        rawKymoFilepath = rawKymoFilepaths{fileNum};

        fprintf('    %s\n', rawKymoFilename);
        rawKymo = double(imread(rawKymoFilepath)); % change how stuff is loaded for new dbm: second tf is image, third tf is bitmask
        rawKymos{fileNum} = rawKymo;
        try
            rawBitmasks{fileNum} = double(imread(strrep(rawKymoFilepath,'kymograph.tif','bitmask.tif')));
            enhanced{fileNum} = double(imread(strrep(rawKymoFilepath,'kymograph.tif','enhanced.tif')));

        catch
        end
    end

    fprintf('All kymograph(s) imported\n');
end