function [rawKymos, rawKymoFilepaths] = import_kymos(defaultRawKymoDirpath)
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
        {'*.tif;*.png;*.mat'}, ...
        'Select kymo file(s) to import', ...
        defaultRawKymoDirpath, ...
        'MultiSelect','on');

    if isequal(rawKymoDirpath, 0)
        rawKymos = cell(0,1);
        rawKymoFilepaths = cell(0, 1);
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
    for fileNum = 1:numFiles
        rawKymoFilename = rawKymoFilenames{fileNum};
        rawKymoFilepath = rawKymoFilepaths{fileNum};
        
        dot = regexp(rawKymoFilename,'\.');
        switch(rawKymoFilename(dot+1:end))

        case 'mat'
%             theoryFilepath = fullfile(dirpath, theoryFilename);

%             theoryData = load(rawKymoFilepath);
%             theoryData = theoryData.theoreticalData;
% 
%             theorySequence = theoryData.completeDNASequence;
            
            kymo = load(rawKymoFilepath);
            kymo = kymo.processedKymo;
            
            rawKymos{fileNum} = arrayfun(@(input) input.kymo_dynamicMeanSubtraction,kymo,'uniformoutput',false);

        case {'tif','png'}
%             theoryFilepath = fullfile(dirpath, theoryFilename);
            rawKymo = double(imread(rawKymoFilepath));
            rawKymos{fileNum} = rawKymo;

            otherwise
            disp('Cannot process file type. Please use a .mat or .fasta file.')
        end

        fprintf('    %s\n', rawKymoFilename);
%         rawKymo = double(imread(rawKymoFilepath));
%         rawKymos{fileNum} = rawKymo;
    end
    
    for fileNum = 1:numFiles
        numKymosInFile = numel(rawKymos{fileNum});
%         if numKymosInFile > 1
        if iscell(rawKymos{fileNum})
%             numKymosInFile = numel(rawKymos{fileNum});
            kymosInFile = rawKymos{fileNum};
            rawKymos{fileNum} = [];
            numKymosToMove = numFiles-fileNum;
            if numKymosToMove == 0
                rawKymos = kymosInFile;
                rawKymoFilepaths(fileNum:fileNum+numKymosInFile-1) = {rawKymoFilepaths{fileNum}};
            else
                for kymoToMove = 0:numKymosToMove-1
                    rawKymos{numFiles + numKymosInFile - kymoToMove - 1} = rawKymos{fileNum - kymoToMove};
                    rawKymos{fileNum - kymoToMove} = kymosInFile{numKymosInFile - kymoToMove};
                    
                    rawKymoFilepaths{numFiles + numKymosInFile - kymoToMove - 1} = rawKymoFilepaths{fileNum - kymoToMove};
                    rawKymoFilepaths{fileNum - kymoToMove} = rawKymoFilepaths{numKymosInFile - kymoToMove};
                end
                
                numFiles = numFiles + numKymosToMove;
            end
%             for shift = 2:numKymosInFile
%                 shift = numKymosInFile - shift + 1;
%                 rawKymos{numKymosInFile+shift} = rawKymos{fileNum+shift};
% %                 rawKymos{fileNum+1+numKymosInFile:end+numKymosInFile} = rawKymos{end-shift+2};
%             end
        end
    end
    
    if ~iscell(rawKymos)
        rawKymos = {rawKymos};
    end

    fprintf('All kymograph(s) imported\n');
end