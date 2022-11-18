function [fileCells, fileMoleculeCells,kymoCells] = hpfl_extract(sets, fileCells)
    % hpfl_odm_extract / extracts molecules.
    
    % tested on:
    %
    % Movies of chromosomal DNA fragments

    % Args:
    %       sets 
    
    % Returns:
    %   kymo - kymographs
    %   kymoW - wide kymographs
    %   noiseKymos - noise kymographs
    


    % pre-load file
%     sets = preload_movie_folder_names(sets);
   
    movieFilenames = sets.movies.movieNames;
%     movieFilenames = fullfile(sets.movies.kymofilefold , sets.movies.filenames);
    numFiles = numel(movieFilenames);

   % Go through each of the files.
    if nargin < 2
        fileCells = cell(numFiles, 1);
    end
    
    fileMoleculeCells = cell(numFiles, 1);

    % params: should be in settings file
    numPts = sets.numPts; % minimum length of barcode
    averagingWindowWidth = sets.averagingWindowWidth; % averaging window width
    distbetweenChannels = sets.distbetweenChannels; % estimated distance between channels
    parForNoise = sets.parForNoise;
    remNonuniform = sets.denoise;

    numFrames = sets.numFrames; % numframes for angle detection
    minLen = sets.minLen;
    stdDifPos = sets.stdDifPos;
    channels = sets.channels;
    max_f = sets.max_f;
    
    max_number_of_frames = sets.max_number_of_frames;
    timeframes = sets.timeframes; % number of time-frames to use to detect positions of nanochannels

    % detect columns with molecule
    farAwayShift = sets.farAwayShift; % how many rows to shift for max coefficient calculation
    channelForDist = sets.channelForDist;
   
    import DBM4.convert_czi_to_tif;

    % 3) load image first frame for mol detection
    tic
    % settingsHPFL.numFrames = 1;
    for idx = 1:length(movieFilenames)
        if nargin >= 2
            kymos=fileCells{idx}.preCells.kymos;
            wideKymos = fileCells{idx}.preCells.wideKymos ;
            posXUpd =  fileCells{idx}.preCells.posXUpd;
            posY = fileCells{idx}.preCells.posY;
            channelForDist =fileCells{idx}.preCells.channelForDist;
%             minLen = fileCells{idx}.preCells.minLen;
%             stdDifPos = fileCells{idx}.preCells.stdDifPos;
            name =  fileCells{idx}.preCells.name;
            meanRotatedMovieFrame =  fileCells{idx}.preCells.meanRotatedMovieFrame;
            maxCol = fileCells{idx}.preCells.maxCol;
        else
            
        name = movieFilenames{idx};
        fprintf('Importing data from: %s\n', name);
        
        [beg,mid,ending] =  fileparts(name);
        if isequal(ending,'.czi')
            data(1).folder = beg;
            data(1).name = strcat(mid,ending);
            disp('Need to convert to czi, running convertion tool');
            [newNames, newInfo ] = convert_czi_to_tif(data,0); % todo: convert fixed number of frames only/ newInfo contains info about file
            name = newNames{1}; 
        end
        
        if max_f == 0
            max_f = inf;
        end
            
        % load data - support multi-channel // take from the first time frame
        [ channelImg,imageData ] = load_first_frame_iris(name,max_number_of_frames, max_f, channels);
        firstIdx = imageData{1}.IntensityInfo.firstIdx;
%         firstIdx = 1; % 
        channels = imageData{1}.info.channels;
%         visual_mean(channelImg{1}{1}) % visualize channel vs mean
%         figure,plot(imageData{1}.IntensityInfo.yData)

        if length(channelImg) == 1 % if single channel
            channelForDist = 1;
            firstIdx = 1;
        end
        number_of_frames = length(channelImg{1}); % maximum number of frames

        %
        disp(strcat(['Image loaded in ' num2str(toc) ' seconds']));
        
        meanMovieFrame = mean(cat(3, channelImg{1}{:}), 3, 'omitnan');
        
        % angle calculated from meanMovieframe or numFrames

        % movie angle
%         [movieAngle, CC, allAngles] = get_angle(channelImg,numFrames,sets.maxMinorAxis, sets.tubeSize);
        [movieAngle, CC, allAngles] = get_angle({{meanMovieFrame}},1,sets.maxMinorAxis, sets.tubeSize);
        % if angle not detected, skip
        
        
        maxCol = [];

        if sets.moleculeAngleValidation
            % TEST ANGLE DETECTION
            pos = -sets.minAngle:sets.angleStep:sets.minAngle;
            for j=pos
%                 j
                % quicker rotation?
                [rotImgT, ~] = rotate_images({{meanMovieFrame}}, movieAngle+j);
    %             meanRotatedMovieFrame = mean(cat(3, rotImg{1}{:}), 3, 'omitnan');
                maxCol = [maxCol max(nanmean(rotImgT{1}{1}))];
            end
            [a,b] = max(maxCol);
            movieAngle = movieAngle+pos(b);
        end
        
        
        tic
        [rotImg, rotMask] = rotate_images(channelImg, movieAngle);
        disp(strcat(['Rotation done in ' num2str(toc) ' seconds']));
        meanRotatedMovieFrame = mean(cat(3, rotImg{1}{:}), 3, 'omitnan');
        
%         visual_mean(rotImg{1}{1}) % visualize channel vs mean

%         se = strel('disk',10)
%         background = imopen(rotImg{1}{1},se);
%         figure,imagesc(background)
%         figure,imagesc(rotImg{1}{1})
%         
%         I2 = imtophat(rotImg{1}{1},strel('disk',15));
%         figure,plot(mean(I2))
%                 figure,plot(mean(rotImg{1}{1}))
% 
%                 figure,imagesc(rotImg{1}{1})

%         figure
%         imagesc(I2)

        % max should be at center
%         visual_mean(meanRotatedMovieFrame)
       

        
        % remove noise. this also calculates central and bg trend
        %     [rotImg,centralTend,bgTrend,bgSub] = remove_noise(rotImg, rotMask);
        [rotImg, centralTend, bgTrend, bgSub,background] = remove_noise_mean(rotImg, rotMask, remNonuniform);
%         visual_mean(rotImg{1}{1}) % visualize channel vs mean

       % now detect channels
        for ch=1:length(rotImg)
            rotImg{ch}{1}(isnan(rotImg{ch}{1}))=0;
        end
     
        %% find lambda molecules
        meanRotatedDenoisedMovieFrame = mean(cat(3, rotImg{1}{:}), 3, 'omitnan');

%         sets.detectlambdas = 1;
        if sets.detectlambdas
            [posX,posYcenter,posMax] = find_short_molecules(meanRotatedDenoisedMovieFrame,sets );
%             plot_result(channelImg,rotImg,rotImg,round(posXlambda),posYlambda(:,1))

        else
            [posX,posMax] = find_mols_corr(rotImg, bgTrend, numPts, channelForDist, centralTend, farAwayShift, distbetweenChannels,timeframes );
            posYcenter = [];
        end
        % find mol positions/ 
        

    
      % background channels
        extPos = [sort(posX) size(rotImg{1}{1},2)];
        diffPeaks =  round(extPos(find(diff([1 extPos]) >= parForNoise))-parForNoise/2);

        meanVal = 0;
        stdVal = bgTrend{1}; % here could use bg kymos for this
        % remove rows that don't have enough signal pixels
        numElts = find(sum(rotImg{1}{1}(:,posX)  > meanVal+3*stdVal) > numPts);
        posXUpd = posX(numElts);
        posYcenter = posYcenter(numElts,:);


        numEltsBg = find(sum(rotImg{1}{1}(:,diffPeaks)  > meanVal+3*stdVal) < numPts);
        diffPeaksBg = diffPeaks(numEltsBg);
       
%     plot_result(channelImg,rotImg,rotImg,posXUpd,posMax)

    % todo: check which is best for SNR/
    tic
    % import AB.create_channel_kymos_one;                                 % for this only one frame in IRIS../bionano would have several
    [kymos, wideKymos,kmChanginW, kmChangingPos] = create_channel_kymos_one(posXUpd,firstIdx,channels,movieAngle,name,number_of_frames,averagingWindowWidth,rotMask,bgSub,background);
   
    disp(strcat(['Barcodes extracted in ' num2str(toc) ' seconds']));
%     figure,imagesc(kymos{1}{1})

%     out.kymos=kymos;
%     out.wideKymos=wideKymos;
%     out.kmChanginW=kmChanginW;
%     out.kmChangingPos=kmChangingPos;

%     kymo=kymos;
%     kymoW=wideKymos;
    % % 
%     chidx=2;
%     f=figure
%     numTiles=length(kymos{chidx});
%     tiledlayout(round(numTiles/5)+1,5)
%     for i=1:numTiles
%         nexttile
%         imagesc(kymos{chidx}{i});colormap(gray)
%     end
    % 
    % what if we can't extract noise kymos?
    [noiseKymos,noisewideKymos] = create_channel_kymos_one(diffPeaksBg,firstIdx,channels,movieAngle, name,number_of_frames,averagingWindowWidth,rotMask,bgSub,background);
    % 
    try
        posY = find_positions_in_nanochannel(noiseKymos,kymos,posYcenter );
    catch
        posY = [];
    end
%     posY = find_positions_in_nanochannel(noisewideKymos,wideKymos );

%     wideKymos

        end
    %% re-saving of these structures based on "nicity" i.e. by filtering could be re-done from here
    preCells.kymos = kymos;
    preCells.wideKymos = wideKymos;
    preCells.posXUpd = posXUpd;
    preCells.posY = posY;
    preCells.channelForDist = channelForDist;
    preCells.minLen = minLen;
    preCells.stdDifPos = stdDifPos;
    preCells.name = name;
    preCells.meanRotatedMovieFrame = meanRotatedMovieFrame;
    preCells.maxCol = maxCol;
    % now final step is to extract "nice" kymographs
    [kymo, kymoW, kymoNames,Length,~,kymoOrig,idxOut] = extract_from_channels(kymos,wideKymos, posXUpd, posY, channelForDist, minLen, stdDifPos);
    
     posY = posY(find(idxOut));
    numMoleculesDetected=length(kymo);
    moleculeStructs = cell(1,numMoleculesDetected);

    for i=1:numMoleculesDetected
        moleculeStructs{i}.miniRotatedMovie = kymoW{i}{1};
        moleculeStructs{i}.kymograph = kymoOrig{i};
        moleculeStructs{i}.kymosMoleculeLeftEdgeIdxs = posY{i}.leftEdgeIdxs;
        moleculeStructs{i}.kymosMoleculeRightEdgeIdxs = posY{i}.rightEdgeIdxs;
        moleculeStructs{i}.moleculeMasks = ~isnan(kymo{i});
        moleculeStructs{i}.rawKymoFileIdxs = i;
        moleculeStructs{i}.rawKymoFileMoleculeIdxs = i;

        % need to add some filters, i.e. is it too close to something?
        % close to the edge? etc
         moleculeStructs{i}.passesFilters = 1;

    end
        if ~isempty(posY)
            poss = cellfun(@(x) round([mean(x.leftEdgeIdxs) mean(x.rightEdgeIdxs)]),posY,'UniformOutput',false)';
        else
            poss = {};
        end
        rowEdgeIdxs = vertcat(poss{:});
        posXUpd2=num2cell(posXUpd(find(idxOut)));
        colCenterIdxs = vertcat(posXUpd2{:});
    
        fileStruct = struct();
        fileStruct.preCells = preCells;
        fileStruct.fileName = name;
        fileStruct.averagedImg = meanRotatedMovieFrame;
        fileStruct.locs = colCenterIdxs;
        fileStruct.regions = rowEdgeIdxs;
        fileStruct.angleCor = maxCol;
        fileMoleculeCells{idx} = moleculeStructs;
        fileCells{idx} = fileStruct;
          
    end
%     [nameS] = save_image(channelImg{2}{1}',channelImg{1}{1}',''); % save for i.e. analysis with optiscan

%     timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
%     outputDirpath=strcat('kymographs',timestamp);
%     mkdir(outputDirpath)
%     
%     numRawKymos = length(rawKymos);
%     outputKymoFilepaths = cell(numRawKymos, 1);
% 
%     for rawMovieIdx=1:length(fileMoleculeCells)
%         numRawKymos = length(fileMoleculeCells{rawMovieIdx});
%         for rawKymoNum = 1:numRawKymos
%             [~, srcFilenameNoExt, ~] = fileparts(movieFilenames{rawMovieIdx});
%             outputKymoFilename = sprintf('%s_molecule_%d_kymograph.tif', srcFilenameNoExt, rawKymoNum);
%             outputKymoFilepath = fullfile(outputDirpath, outputKymoFilename);
%             fileMoleculeCells{rawMovieIdx}{rawKymoNum}.kymograph(isnan(fileMoleculeCells{rawMovieIdx}{rawKymoNum}.kymograph)) = 0;
%             imwrite(uint16(fileMoleculeCells{rawMovieIdx}{rawKymoNum}.kymograph), outputKymoFilepath, 'tif');
%             
%             outputKymoFilename = sprintf('%s_molecule_%d_bitmask.tif', srcFilenameNoExt, rawKymoNum);
%             outputKymoFilepath = fullfile(outputDirpath, outputKymoFilename);
%             imwrite(uint16(fileMoleculeCells{rawMovieIdx}{rawKymoNum}.moleculeMasks), outputKymoFilepath, 'tif');
% 
% %         fileMoleculeCells{rawMovieIdx}
%         end
%         
%         
%     end

    % save kymos into single structure
    kymoCells = [];
    kymoCells.rawKymos = [];
    kymoCells.rawBitmask = [];
    kymoCells.rawKymoFileIdxs = [];
    kymoCells.rawKymoFileMoleculeIdxs = [];
    kymoCells.rawKymoName = [];
    kymoCells.rawBitmaskName = [];
    for rawMovieIdx=1:length(fileMoleculeCells)
        numRawKymos = length(fileMoleculeCells{rawMovieIdx});
        for rawKymoNum = 1:numRawKymos
            [~, srcFilenameNoExt, ~] = fileparts(movieFilenames{rawMovieIdx});
            kymoCells.rawKymos{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.kymograph;
            kymoCells.rawBitmask{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.moleculeMasks;
            kymoCells.rawKymoFileIdxs(end+1) = rawMovieIdx;
            kymoCells.rawKymoFileMoleculeIdxs(end+1) = rawKymoNum;
            kymoCells.rawKymoName{end+1} = sprintf('%s_molecule_%d_kymograph.tif', srcFilenameNoExt, rawKymoNum);
            kymoCells.rawBitmaskName{end+1} =  sprintf('%s_molecule_%d_bitmask.tif', srcFilenameNoExt, rawKymoNum);
        end
    end

    

end

% 
% function sets=preload_movie_folder_names(sets);
%     if ~sets.movies.askForMovies % if movies already provided in input file (supports scripting)
%         try 
%             fid = fopen(sets.movies.movieFile); 
%             fastaNames = textscan(fid,'%s','delimiter','\n'); fclose(fid);
%             for i=1:length(fastaNames{1})
%                 [FILEPATH,NAME,EXT] = fileparts(fastaNames{1}{i});
% 
%                 sets.movies.filenames{i} = strcat(NAME,EXT);
%                 sets.movies.kymofilefold{i} = FILEPATH;
%             end
%         catch
%             sets.movies.askForMovies   = 1;
%         end
%     end
% 
%     if sets.movies.askForMovies
%         % loads figure window
%         import Fancy.UI.Templates.create_figure_window;
%         [hMenuParent, tsDBM] = create_figure_window('DBM movie import tool','DBM');
% 
%         import Fancy.UI.Templates.create_import_tab;
%         cache = create_import_tab(hMenuParent,tsDBM,'movie');
%         uiwait(gcf);  
% 
%         dd = cache('selectedItems');
%         sets.movies.filenames = dd(1:end/2);
%         sets.movies.kymofilefold = dd((end/2+1):end);
%         delete(hMenuParent);
%     end
% 
% end
%     
    
% function to load the first frame
function [channelImg, imageData] = load_first_frame_iris(moleculeImgPath, max_number_of_frames,numFrames,channels)
    % for irys data

%     try
%         % info about movie
%         %                 tic % if there's info in image description, extract it here
%         obj  = Tiff(moleculeImgPath);
%         data = strsplit(getTag(obj,'ImageDescription'),'\n');
%         chInfo =data(contains(data,'channels'));
%         frInfo =data(contains(data,'frames'));
%         eval(chInfo{1});
%         eval(frInfo{1});
%         firstFrame = 0;
% %         channels = 1; % default is 2
% %         numFrames = min(numFrames,frames);
% 
%     catch

    if nargin < 3
        numFrames = inf;
    end
    
    firstFrame = 0;
    if nargin < 4
        channels = 1;
    end
    
    if channels==1
        firstFrame = 1;
    end
    
    data = imfinfo(moleculeImgPath);
    frames = length(data);
%     channels = 1; % default is 2
%     end
    allDat = imfinfo(moleculeImgPath);
    
    if max_number_of_frames~=0
        maxFr = min(max_number_of_frames,length(allDat)/channels);
    else
        maxFr = frames;
    end
    
    % this saves multiplechannels, single field of view
    i=1;
    imageData{i}.frameMeans = arrayfun(@(x)  mean(imread(moleculeImgPath,x),[1 2]),i:channels:maxFr,'UniformOutput',true);

    disp('Assuming channel 1 to be reference (YOYO) channel');
    
    % fit a line and start from first larger than
    yData =  imageData{1}.frameMeans;
    [~,firstIdx] = max(yData);
    if firstFrame==1
        firstIdx = firstFrame;
    end

    disp(strcat(['Assuming that images start from ' num2str(firstIdx)]));

%     if channels~=1
    numFrames = min(numFrames,frames/channels-firstIdx+1);
%     end

    % also want to substract background, here already?
    channelImg = cell(1,channels);
    imageData =  cell(1,channels);
    for i=1:channels % check the flow direction (should be top to bottom)
        channelImg{i} = arrayfun(@(x) double(imread(moleculeImgPath,x)),i+(firstIdx-1)*(channels):channels:(firstIdx-1)*(channels)+numFrames*channels,'UniformOutput',false);
    end
    
    imageData{1}.IntensityInfo.firstIdx = firstIdx;
    imageData{1}.IntensityInfo.yData = yData;
    imageData{1}.info.all = data;
    imageData{1}.info.channels = channels;


end


% function to averge over estimated angles
function [deg,CC,frameAngle] = get_angle(channelImg, numFrames, maxMinorAxis, tubeSize)
%
%   Returns angle and compted estimate of connected components in those
%   images

% https://en.wikipedia.org/wiki/Mean_of_circular_quantities#Mean_of_angles
%
% Inputs:

%     if nargin < 2
%         % number of frames to try on to get something accurate/while still
%         % computationally efficient time
%         fieldsOfView = length(channelImg{1});
%     end

    if nargin < 2
        numFrames = 10;
    end
    
    if nargin < 3
        maxMinorAxis = 5;
    end
    
    if nargin < 4
        tubeSize = 10;
    end
%     import restimate_angle;

    frameAngle = cell(1,min(numFrames,length(channelImg{1})));
    CC = cell(1,min(numFrames,length(channelImg{1})));

    % estimate angle for each field of view, for first channel
%     for j=1:fieldsOfView                        % take only first frame here for now. Could take mean
    for k=1:min(numFrames,length(channelImg{1}))
        [frameAngle{k}, CC{k}] = estimate_angle(channelImg{1}{k}, maxMinorAxis, tubeSize); %cellfun(@(x) estimate_angle(x),channelImg{1}{j},'un',false);
        if CC{k}.NumObjects<1 % for one object could still calculate?
            frameAngle{k} = nan;
        end
    end
%     end
    % convert to single vector and remove nan's
%     allAngles = cellfun(@(y) cellfun(@(x)  x,y,'un',true),frameAngle,'un',false);
% frameAngle
    frameAngle = cell2mat(frameAngle);
    frameAngle = frameAngle(~isnan(frameAngle));



    [x,y] = pol2cart(frameAngle*pi/180,1);
    deg = rad2deg(atan2(sum(y), sum(x)));
%     deg = rad2deg(atan2(mode(y), mode(x)));
    if length(frameAngle)==2 % if only two features, sum will be weird.
        deg = frameAngle(1);
    end

end


% function to estimate angle
function [allAngles,CC] = estimate_angle(img, maxMinorAxis,tubeSize)

    if nargin < 3
        tubeSize = 5;
    end
    
    if nargin < 2
        maxMinorAxis = 5; % depends on psf
    end
%     if nargin < 2 
%         maxDev = 2;
%         maxMinorAxis = 5;
%         numPeaks = 1;
%     end

    % [1] Frangi, Alejandro F., et al. Multiscale vessel enhancement filtering. Medical Image Computing and Computer-Assisted Intervention — MICCAI'98. Springer Berlin Heidelberg, 1998. pp. 130–137. 

%     angle =[];
     %  run the old filtering
    minVal = double(min(img(:)));
    maxVal = double(max(img(:)));
    % scale the movie to [0,1]
    avg = (double(img) - minVal)./(maxVal - minVal);
%     clear grayscaleVideo;

%     % amplify movie
%     gaussianKernel = fspecial('gaussian', [4,4], 1);

    amplificationFilterKernel = ones(3,3);
    amplificationFilterKernel(floor((end +1)/2),floor((end +1)/2)) = 0;
    amplificationFilterKernel = amplificationFilterKernel./sum(amplificationFilterKernel(:));
    meanGrayFrame = convn(avg, amplificationFilterKernel, 'valid').*avg(1:end-2,1:end-2);

    % add fibermetric as per paper
    J = fibermetric(meanGrayFrame,tubeSize,'ObjectPolarity','bright');
    
% figure,imagesc(J)
% 
%     
% 	BW = imbinarize(J,'adaptive');

	BW = imbinarize(J);%,'adaptive');
    % removes all regions that have fewer than 100 pixels
    BW2 = bwareaopen(BW, 150,4); % tunable? Could keep only object which are very "flat"
%     figure,imshowpair(J',BW2', 'Scaling'  ,'None')
%     BW3 = imtophat(BW,strel('disk',50));
% CH_objects = bwconvhull(BW2,'objects');
%     out = bwskel(BW2,'MinBranchLength',10);

    % also need to remove features which seem to be very close to each
    % other
    % connected components
%     tic
    CC = bwconncomp(BW2); % this already saved for processing?
%     toc
    stats = regionprops('table',CC,'Centroid',...
    'MajorAxisLength','MinorAxisLength','Orientation');
% remove elements that have axis larger than..
%     BW2(cell2mat(CC.PixelIdxList(stats.MinorAxisLength>maxMinorAxis)') ) = 0;
%     A = labelmatrix(CC);
%     
%     thetas = -maxDev:0.01:maxDev;
%     [H,theta,rho] = hough(BW2,'Theta',thetas);
% 
%     peaks = houghpeaks(H,min(numPeaks,CC.NumObjects));
%     allAngles = theta(peaks(:,2));
%     
    allAngles = stats.Orientation(stats.MinorAxisLength<maxMinorAxis)';
%     [x,y] = pol2cart((allAngles)*pi/180,1); % -90 and 90 is the same
%     
%     deg = rad2deg(atan2(sum(y), sum(x)));
    
end

% function to rotate images
function [resizedImgRot,rotMask] = rotate_images(channelImg,movieAngle)
    % rotate image. do proper interpolation
    sz = size(channelImg{1}{1});
%     interpimg = imresize(channelImg{1}{1}{1}, [5*sz(1) 5*sz(2)], 'bilinear');
%     rotim = imrotate(double(interpimg), -(90+movieAngle), 'bilinear');
%     rotimUpd = imresize(rotim,[max(sz) min(sz)]);% get proper size..
    
    method = 'bilinear'; %bicubic
    resSize = 5;
    % resize images to bigger
%     tic
    resizedImg = cellfun(@(y) cellfun(@(z) ...
            imresize(double(z),  [resSize*sz(1) resSize*sz(2)], method), y, 'un',false),channelImg,'un',false);
    % rotate image
    rotImg = cellfun(@(y) cellfun(@(z) ...
        imrotate(double(z), -(90+movieAngle), method), y, 'un',false),resizedImg,'un',false);
% 
    sz2 = size(rotImg{1}{1});
    % resize back to smaller.
    resizedImgRot = cellfun(@(y) cellfun(@(z) ...
        imresize(double(z),  [round(sz2(1)/resSize) round(sz2(2)/resSize)], method), y, 'un',false),rotImg,'un',false);
% 
%     toc
    % test: can see how much bilinear operation 3 times reduces the quality
    % of the data
%         % want to plot rotImg. 
%         img = cell2mat(cellfun(@(x) x{1},rotImg{1},'un',false)');
%         figure,imagesc(img)
        
%         figure,imagesc(cell2mat(rotImg{1}'))
        
        % This is enough for first
        % 90 degrees since we want molecules to be rotated vertically
        % // crop for bionano
        if nargout >1
            mask = ones(resSize*sz);
            rotMask2 = imrotate(mask, -(90+movieAngle), method);
    %         rotMask2(rotMask2==0)=nan;
            rotMask = imresize(rotMask2,  [round(sz2(1)/resSize) round(sz2(2)/resSize)], method);
            rotMask = rotMask <= 0.99;
    %         imrotate(mask, -(90+movieAngle), 'bilinear')~=1;
            nonzeronum = sum(rotMask==0);
            maxsum = 0.99*max(nonzeronum); 
            % make sure that values interpolated with outside are nan's
            for i=1:length(resizedImgRot)
                for k=1:length(resizedImgRot{i})
                    resizedImgRot{i}{k}(rotMask) = nan;
                    resizedImgRot{i}{k}(:,nonzeronum<maxsum) = nan; % remove columns with few pixels to get rid of edge effects
                end
            end
        end

end

function [rotImg, meanTrend, bgTrend, firstMeanPrediction,background] = remove_noise_mean(rotImg, rotMask,remNonuniform,firstMeanPrediction,background)
 
    % Args:
    %   rotImg, rotMask
    %
    %   Returns:
    %       rotImg,medianS,bgTrend,bgSub
        if nargin >=4
            for i=1:length(rotImg)
                for k=1:length(rotImg{i})
                    rotImg{i}{k}(rotMask) = nan;
                    if remNonuniform
                        rotImg{i}{k} =  rotImg{i}{k}-firstMeanPrediction(i)-background{i};
                    else
                        rotImg{i}{k} =  rotImg{i}{k}-firstMeanPrediction(i);
                    end
                    rotImg{i}{k}(rotImg{i}{k} < 0 ) = nan;
                end
            end
        else
   
        if remNonuniform==1
            for ii=1:length(rotImg) % iterate through different fields of view.
                se = strel('disk',15);
%                 se = strel('rectangle',[100 20]);
                imgtest = rotImg{ii}{1};
                imgtest(isnan(imgtest)) = nanmin(imgtest(:));

                background{ii} = imopen(imgtest,se);
                background{ii}(rotMask) = nan;
                
%                 figure,plot(nanmean(  background{ii}'))
%                 hold on
%                 plot((nanmean( rotImg{ii}{1}')))
%             for ii=1:length(rotImg)
%                 for k=1:length(rotImg{ii})
%                     rotImg{ii}{k}(isnan(rotImg{ii}{k})) = min(rotImg{ii}{k}(:));
%                     rotImg{ii}{k} = imtophat(rotImg{ii}{k},strel('disk',15));
%                     rotImg{ii}{k}(~rotMask) = nan;
%                 end
%             e
            end
        else
            for ii=1:length(rotImg) 
                background{ii} = 0;
            end
%         else
% 
%             for ii=1:length(rotImg) % iterate through different fields of view.
% 
%             end
        end
        
        
        %% maybe iterative procedure?
        
        for ii=1:length(rotImg) % iterate through different fields of view.
        % temporary signal frame
            if remNonuniform==1
                tmp = rotImg{ii}{1}-background{ii};
            else
                tmp = rotImg{ii}{1};
            end

            tmp(rotMask) = nan;
            nnztmp  = tmp(tmp~=0);
            
            firstMeanPrediction(ii) = nanmean(nnztmp);
            bgTrend{ii} = nanstd(nnztmp(nnztmp<firstMeanPrediction(ii)));
        
            signalPoints = nnztmp(nnztmp>firstMeanPrediction(ii)+4*bgTrend{ii});
        
    %         bgSub = 
            if length(signalPoints)>1000
                meanTrend{ii} = mean(signalPoints)-firstMeanPrediction(ii);
            else
                sortvals = sort(tmp(:),'desc','MissingPlacement','last');
                meanTrend{ii} = nanmean(sortvals(1:1000))-firstMeanPrediction(ii);
            end

            for k=1:length(rotImg{ii})
                rotImg{ii}{k}(rotMask) = nan;
                rotImg{ii}{k} =  rotImg{ii}{k}-firstMeanPrediction(ii);
                if remNonuniform==1
                    rotImg{ii}{k}  =  rotImg{ii}{k}  - background{ii};
                end
            %             rotImg{1}{k}(rotImg{1}{k} < 0 ) = nan;
            end
        
        end
        end
        

end
% function to remove noise based on mean of a column
function [rotImg,medianS,bgTrend,bgSub] = remove_noise(rotImg, rotMask,bgSub)
    % removes noise from images, based on column with signal
    
    % Args:
    %   rotImg, rotMask,bgSub
    %
    %   Returns:
    %       rotImg,medianS,bgTrend,bgSub
    
    if nargin >=3
        for i=1:length(rotImg)
            for k=1:length(rotImg{i})
                rotImg{i}{k}(rotMask) = nan;
                rotImg{i}{k} =  rotImg{i}{k}-bgSub(i);
                rotImg{i}{k}(rotImg{i}{k} < 0 ) = nan;
            end
        end
    else
        
        %% maybe iterative procedure?
        
        % temporary signal frame
        tmp = rotImg{1}{1};
        tmp(rotMask) = nan;
        %
%         data=tmp(~isnan(tmp));
%         lenD = length(data);
% %         data(isn
%         
%         s=buffer([data; nan(5*ceil(lenD/5)-lenD,1)],ceil(lenD/5),0); 
%         medianPos = nanmedian(s,1);
%         signalPx = tsRow(tsRow>multithresh(s));

%         tmp= sqrt(rotImg{1}{1}.*rotImg{2}{1});

%         tmp(isnan(tmp))=min(tmp(:));
%         BW = imbinarize(tmp);%, 'adaptive');
% figure,imagesc(BW)

        % find position and median of max. Don't consider the rows close to
        % the edges (as they might have bad ilumination?
        medianPos = nanmedian(tmp,1);
        if size(tmp,2)>100
            medianPos(1:10) = nan;
            medianPos(end-9:end) = nan;
        end
        
        [PKS,bestCol]= findpeaks(medianPos,'SortStr','descend','NPeaks',5+1);
        % should we consider outlier?
        if length(PKS)> 1
            bestCol = bestCol(2:end); %ignore the first in case outlier
        end

%         [a,b] = sort(medianPos,'descend');
%         b(isnan(a)) = [];
%         a(isnan(a)) = [];
%         
%         % if all the best cols are around same place, take second best
%         bestCol = b(1:5); % take some of best columns

%         [meansig,pos]= max(medianPos); % bitmasksignal
%         medianPos(pos) = nan;
%         [meansig2,pos2]= max(medianPos); % bitmasksignal

        
        % take the row with this position
        tsRow = tmp(:,bestCol);
        % keep only pixels above thresh
        signalPx = tsRow(tsRow>multithresh(tsRow));
        colMean = nanmean(signalPx);% signal mean estimate
        colStd =  nanstd(signalPx);% signal std estimate
        % Now find signal pixels in the whole image. This will be lower
        % than colMean
        
        medianS{1} = nanmedian(tmp(tmp>colMean-2*colStd)); % so if the signal too close to background, this will include bcg as well
%         % bitmask these signal pixels
        if length(tmp(tmp<colMean-colStd))>100 % if some pixels are counted as signal pixels
            tmp(tmp>colMean-colStd) = nan;
        else
            error('Can not find signal pixels')
            medianS{1} = nanmedian(tmp(:));
        end
        colMean = nanmedian(tmp(:)); % estimate background
        medianS{1} = medianS{1}- colMean;
        mask = ~isnan(tmp);
        bgTrend{1}  = nanstd(tmp(:),1);
        bgSub(1)=colMean;

        for k=1:length(rotImg{1})
            rotImg{1}{k}(rotMask) = nan;
            rotImg{1}{k} =  rotImg{1}{k}-colMean;
%             rotImg{1}{k}(rotImg{1}{k} < 0 ) = nan;
        end

        % remove noise from
        for i=2:length(rotImg)
                % we compute noise for the first image (assume it does not
            % change significantly over time..
            tmp = rotImg{i}{1}(mask);

            colMean = nanmedian(tmp,1);
    %         tmp(rotMask) = nan;
    %         % assuming there are some channels with no molecules, minimum of
    %         % these should ge
    %         meansig = max(nanmean(tmp,1)); % bitmasksignal
%             if length(tmp(tmp<colMean-5*colStd))>100 % if some pixels are counted as signal pixels
                medianS{i} = nanmedian(rotImg{i}{1}(~mask))-colMean;
%             else
%                  medianS{i} = 0;
%             end
    % 
    %         tmp(tmp>meansig-2*nanstd(tmp(:))) = nan;
    %         colMean = nanmedian(nanmean(tmp,1)); % estimate background
            bgTrend{i}  = nanstd(tmp(:),1);
            bgSub(2)=colMean;

    %         centralTend{i} = centralTend{i}- colMean;
            for k=1:length(rotImg{i})
                rotImg{i}{k}(rotMask) = nan;
                rotImg{i}{k} =  rotImg{i}{k}-colMean;
                rotImg{i}{k}(rotImg{i}{k} < 0 ) = nan;
            end

        end
    end
end

            % minimum 
    %         min(colMean)
    %         tmp = tmp-colMean;
    %         tmp(tmp<0) = 0;


function [posX,posMax] = find_mols_corr(rotImg,bgTrend,numPts,channelForDist,centralTend,farAwayShift, distbetweenChannels,timeframes );
        
        meanVal = 0;
        stdVal = bgTrend{1};
        relevantRows = find(sum(rotImg{1}{1}  > meanVal+3*stdVal) > numPts);
        allrows = 1:size(rotImg{1}{1},2);
        allrows(relevantRows)=0;

        for ch=1:length(rotImg)
            rotImg{ch}{1}(:,find(allrows))=nan;%min(rotImg{2}{1}(:));
        end
        % Now find molecules..


        tic
        % import AB.find_molecules;      %  1:settingsHPFL.numFrames
        [height, posX, peakMat, peaksToPlot, peakcc, peakint,corrM,posMax] =  ...
            find_molecules({rotImg{channelForDist}{1}},numPts,centralTend{channelForDist},...
        farAwayShift, distbetweenChannels,timeframes)  ;
        disp(strcat(['Channel detection done in ' num2str(toc) ' seconds']));
        %
end
        
    
function [height,peakpos,peakMat, peaksToPlot, peakcc,peakint,corrM,maxPos] = find_molecules(rotImg,numPts,meanSignal,...
    farAwayShift, distbetweenChannels,timeframes)
    % find_molecule_channels

    % when computing the correlation, don't consider the whole column, but
    % just the subset of the column
    % This function finds molecule channels
    
    if nargin < 2
        numPts = 100; % num points basically describes smallest barcode length in nanochannel
    end
    
%     if size(rotImg{1},2) <
    if nargin < 5
        % that we want to detect
        farAwayShift = 50; % how many rows to shift for max coefficient calculation
        distbetweenChannels = 4; % estimated distance between channels
        timeframes = 50;
    end
    
    % options: 2 concequtive images, or two concequtive rows
    
%     import AB.find_column_max;
    
    if length(rotImg) == 1 || timeframes==1 % in case of a single image,
        compareY = 1;
        % use different columns in y rather than z direction
        rotImg{2} = circshift(rotImg{1},[0,1]);
%         rotDist{2} = circshift(rotDist{1},[0,1]);
        rotImg{1}(:,1:8)=nan;
        rotImg{1}(:,end-7:end)=nan;

    else
        compareY = 0;
    end
    
    peakMat = zeros(length(rotImg)-1,size(rotImg{1},2));
    peaks = cell(1,length(rotImg)-1);
    
    % don't want to run comparison for all possible positions, but smaller
    % fraction. So don't need fft's. Or instead of pcc, just compare
    % intensities?
    [maxFirst, posFirst] = max(rotImg{1});

    corrsFarAway = find_column_max(rotImg{1},circshift(rotImg{2},[0,farAwayShift]),posFirst,numPts);
%     corrsFarAway2 = find_column_max(rotImg{1},circshift(rotImg{2},[0,farAwayShift+2]),posFirst,numPts);
%     corrsFarAway3 = find_column_max(rotImg{1},circshift(rotImg{2},[0,farAwayShift+4]),posFirst,numPts);


%     corrsFarAway = find_column_max(rotImg{1},circshift(rotImg{2},[0,farAwayShift]),posFirst,numPts);
%     sortedCors =  sort(corrsFarAway);
%     % take maximum of far away coefficients. 
%     ccThresh = sortedCors(end-2); % take one of the last
%     ccThresh = 0.4;
    ccThresh = max(corrsFarAway); % these might still correlate if we manage to shift unluckily.. maybe shift a few times and take average?
    if isnan(ccThresh)
        ccThresh = 0; % if it's a nan, then all columns are signal columns or next to signal columns and should be acceptable
    end
    
    corrM = cell(1,min(timeframes,length(rotImg)-1));
    for i=1:min(timeframes,length(rotImg)-1)
        %i
        corrs = find_column_max(rotImg{i},rotImg{i+1},posFirst,numPts);
        corrM{i} = corrs;
   
        corrs(isnan(corrs))=0;
        % find the peaks
        [peakcc, peakpos] = findpeaks(corrs,'MinPeakDistance',distbetweenChannels);
        
        % find peak positions
        peaksToPlot = peakpos(peakcc>ccThresh);
        peakint = maxFirst(peaksToPlot);
        peakcc = peakcc(peakcc>ccThresh);

        if compareY
            % check which one is higher
            columnMax =  max(rotImg{i+1}) > maxFirst; % column maximum
            % has to be a -, since i+1  contains a previous value..
            peaksToPlot = peaksToPlot-double(columnMax(peaksToPlot));
        end
        % correct the position if the second column has the maximum intensity

        [maxFirst, posFirst] = max(rotImg{i+1});
        peakMat(i,peaksToPlot) = 1;
        peaks{i} = peaksToPlot;
    end
    [maxV] = max(rotImg{1});
    maxV(isnan(maxV)) = 0;
    % number of peaks
    if size(peakMat,1) > 3
        numberPeaks = sum(peakMat);
           [height,peakpos] = findpeaks(numberPeaks,'MinPeakHeight',...
        min(timeframes,length(rotImg))/4,'MinPeakDistance',distbetweenChannels);
% 
    else
        peakMat(maxV < meanSignal) = 0; % a bit more careful with meanSignal, so meaningful channels are not lost
        numberPeaks = peakMat;
           [height,peakpos] = findpeaks(numberPeaks.*maxV,'MinPeakHeight',...
        min(timeframes,length(rotImg))/4,'MinPeakDistance',distbetweenChannels);
% 
    end
        
        
        % numberPeaks = movsum(sum(peakMat),3,'Endpoints','discard' );
        % there should not be any close together
%         [height,peakpos] = findpeaks(numberPeaks,'MinPeakHeight',...
%             min(timeframes,length(rotImg))/4,'MinPeakDistance',distbetweenChannels);
%     else
        
    maxPos = posFirst(peakpos);

 
%             
% % % 
%     import Plot.plot_image_with_peaks;
% 	plot_image_with_peaks(rotImg{1},peakpos)


%     import Plot.plot_image_with_peaks;
% 	plot_image_with_peaks(rotImg{1},peakpos)

end
    
% find column max
function [corrs] = find_column_max(image1, image2, pos, numPts)
    % find_channels_based_on_corr
    %
    %   Args:
    %       image,dist
    %   
    %   Returns:
    %
    %       corrs
    
%     % each peak in correlation corrs corresponds to a peak in columnMeans.
    % these peaks can be shifted a little bit, since we don't exactly hit
    % the peak with the mean (it might be to the left or to the right of
    % the detected peak position), and corrs finds the correlation between 
    % i'th and i+1 column, so for the pixel for continued classification,
    % we need to use max (or mean) between i and i+1 intensities in A. This
    % can be written as
    numPoints2 = size(image1,2);
    corrs = zeros(1,numPoints2);
%     corrs2 = zeros(1,numPoints);

%     [maxVals,pos] = max(image1);
    
    % now we want to run a PCC comparison for rows based on pos, and make
    % sure that each row has same number of elements, and that zero rows
    % are not taken into account. % maybe limit to not consider a few point
    % at the edges
    edgePts = 5; % sometimes more/less, depending on rotation..
    
    % so we have pos(i)
    %
    % we want a 100px window including pos(i) (preferably in the center)
    limits = [edgePts size(image1,1)-edgePts+1];
% 	locs = [pos-numPts/2; pos+numPts/2-1]; % instead choose based on whether max is to left or right
    
    % function: expand from pos left and right for total of numPts,
    % expand left right pos
    [st, stop] = arrayfun(@(x) local_window(pos(x),image1(:,x),numPts),1:size(image1,2));
    locs = [st;stop];
    %     image1(pos(1)-numPts:pos(1)+numPts,111)
% [a,b] = local_window(pos(1),image1(:,1),numPts)
    % shift a bit if it touches edge zone
    diff1 = locs(1,:)-limits(1);
    locs(2,diff1<0) = locs(2,diff1<0) -diff1(diff1<0);
    locs(1,diff1<0) = edgePts;
    diff2 = limits(2)-locs(2,:);
    locs(1,diff2<0) = locs(1,diff2<0) +diff2(diff2<0);
    locs(2,diff2<0) = limits(2);
    
    
    for i=1:numPoints2     
        bar1 = image1(locs(1,i):locs(2,i),i);
        bar2 = image2(locs(1,i):locs(2,i),i);
        
%        bar1 = imgaussfilt(image1(locs(1,i):locs(2,i),i),1.2);
%         bar2 = imgaussfilt(image2(locs(1,i):locs(2,i),i),1.2);
  
        % compute correlations
        % should only across nonzero entriess
%         bar1'/nanstd(bar1,1)*bar2/nanstd(bar2,1);
%         corrs(i) = zscore(bar1')*zscore(bar2)/numPts;   
        sq1= sqrt(bar1'*bar1);
        sq2 = sqrt(bar2'*bar2);
        if sq1==0
            sq1 = inf;
        end
        if sq2==0
            sq2 = inf;
        end
        corrs(i) = bar1'/sq1*bar2/sq2;%/numPts;   
    end
% 
%     figure,plot(zscore(bar1))
%     hold on
%     plot(zscore(bar2))
%     
%     i=110
%     figure;plot(zscore(image1(:,i))+5);
%     hold on;plot(zscore(image2(:,i))+5);
%     hold on;
%     plot(locs(1,i):locs(2,i), zscore(image1(locs(1,i):locs(2,i),i)));
%     plot(locs(1,i):locs(2,i), zscore(image2(locs(1,i):locs(2,i),i)));
%     bar1 = image1(locs(1,i):locs(2,i),i);
%     bar2 = image2(locs(1,i):locs(2,i),i);

%     zscore(bar1')*zscore(bar2)/numPts
%     pos(i)
%     locs(1,i)
%     locs(2,i)
%     
%      [st, stop] = local_window(pos(i),image1(:,i),150)
    
%     zscore(bar1')*zscore(circshift(bar2,[0,0]))/numPts

    
end
% 
function [st, stop] = local_window(posA,barcode,numPoints)
%     vals = 1;
    st = posA;
    stop = posA;
    for i=1:numPoints-1
       if (st>1) && (stop < length(barcode)-1) && (barcode(st) > barcode(stop))
           st = st-1;
       else
           if (st>1)
               st = st-1;
           else
               stop = stop+1;
           end
       end
    end
% 
end
% 

function [kymos, wideKymos,kymosDifferentwidth, kymosDifferentPos] = create_channel_kymos_one(peakpos, firstIdx,channels,movieAngle, name,max_number_of_frames,averagingWindowWidth,rotMask,bgSub,background)
    % create_channel_kymos - create kymos for each of the channels
    % this version loads frames on by one.
    if nargin < 2
        averagingWindowWidth = 3;
    end
    
%     import Import.load_rot_img;

    
    % for each peakpos, we create a kymo
%     rotImg(rotImg==0) = nan;
    kymos = cell(1,length(channels));
    wideKymos = cell(1,length(channels));
    kymosDifferentPos = cell(1,length(peakpos));

    kymosDifferentwidth =  cell(1,length(peakpos));
    numSegsLeft = floor((averagingWindowWidth-1)/2);
    numSegsRight = floor(averagingWindowWidth/2);
    averagingWindowWidthMax = 5;
    adddetail = 1;
    % if there is no setting about the details
%     if ~isfield(settings,'adddetail')
%         settings.adddetail = 1;
%     end
    
    
    % what to do if too many frames are selected, make sure this does not
    % error. This just takes average over the time frames.
    for idx=1:max_number_of_frames % this loop can be outside this function!
       try
           % load image. Important, this rotates & also removes backgroun
           rotImg = load_rot_img(name,firstIdx+idx-1,channels,movieAngle,1,rotMask,bgSub,background);
            for j=1:length(rotImg) % go through different channels. Could be a cellfun to remove the loop
                rotImg{j}{1}(rotImg{j}{1}==0) = nan;
                    for idy=1:length(peakpos) % different peak positions. Could be cellfun
                        % main part: take some segs left and some right
                        img = rotImg{j}{1}(:,max(1,peakpos(idy)-numSegsLeft):min(end,peakpos(idy)+numSegsRight),:);% should also write out how many rows we took in case not all..
                        img(img==0)=nan;
                        kymos{j}{idy}(idx,:) =  nanmean(img,2); 
                        
                        if adddetail
                            wideKymos{j}{idy}{idx} = img;
                            %% extra.. first create kymographs for different averaging window widths

                            for k =1:averagingWindowWidthMax
                                numSegsLeftT = floor((k-1)/2);
                                numSegsRightT = floor(k/2);
                                img = rotImg{j}{1}(:,max(1,peakpos(idy)-numSegsLeftT):min(end,peakpos(idy)+numSegsRightT),:);
                                kymosDifferentwidth{idy}{j}{k}(idx,:) =  nanmean(img,2); 

                            end

                            for k =-averagingWindowWidthMax:averagingWindowWidthMax
                                img = rotImg{j}{1}(:,max(1,peakpos(idy)+k):min(end,peakpos(idy)+k),:);

                                kymosDifferentPos{idy}{j}{k+averagingWindowWidthMax+1}(idx,:) =  nanmean(img,2); 

                            end
                        end
                        
                        %% end extra
                    end
            end
       catch
           break
       end
    end
%     end
%         settings
%     % reduce number of loops..
%    for j=1:length(rotImg) % for each row
%         rotImg{j}(rotImg{j}==0) = nan;
%         for idx=1:length(peakpos)
%             img = rotImg{j}(:,max(1,peakpos(idx)-numSegsLeft):min(end,peakpos(idx)+numSegsRight),:);% should also write out how many rows we took in case not all..
%             img(img==0)=nan;
%             kymos{idx}(j,:) =  nanmean(img,2); 
%             wideKymos{idx}{j} = img;
%         end
%    end
%    
%        % reduce number of loops..
%    for j=1:length(rotImg) % for each row
%         rotImg{j}(rotImg{j}==0) = nan;
%         for idx=1:length(peakpos)
%             img = rotImg{j}(:,max(1,peakpos(idx)-numSegsLeft):min(end,peakpos(idx)+numSegsRight),:);% should also write out how many rows we took in case not all..
%             img(img==0)=nan;
%             kymos{idx}(j,:) =  nanmean(img,2); 
% %             wideKymos{idx}{j} = img;
%         end
%    end
   
   
    % reduce number of loops..
%     for j=1:length(rotImg) % for each row
%         for k =1:settings.averagingWindowWidth
%             numSegsLeft = floor((k-1)/2);
%             numSegsRight = floor(k/2);
%             for idx=1:length(peakpos)
%                 img = rotImg{j}(:,max(1,peakpos(idx)-numSegsLeft):min(end,peakpos(idx)+numSegsRight),:);
% %                 img(img==0)=nan;
%                 kymosDifferentwidth{k}{idx}(j,:) =  nanmean(img,2); 
% %                 wideKymos{idx}{j} = img;
%             end
%            
%         end
%     end
    
%        
%     t = 1;
%     side = ceil(settings.averagingWindowWidth/2);
%     % reduce number of loops..
%     for j=1:length(rotImg) % for each row
%         for k =1:settings.averagingWindowWidth
%             for idx=1:length(peakpos)
%                 img = rotImg{j}(:,max(1,peakpos(idx)+k-side):min(end,peakpos(idx)+k-side),:);
% %                 img(img==0)=nan;
%                 kymosDifferentPos{k}{idx}(j,:) =  nanmean(img,2); 
% %                 wideKymos{idx}{j} = img;
%             end
%            
%         end
%     end

end

function [rotImg] = load_rot_img(moleculeImgPath, firstIdx,channels, movieAngle, max_number_of_frames,rotMask,bgSub,background)

    % first load the required number of frames

        % also want to substract background, here already?
    channelImg = cell(1,channels);
    imageData =  cell(1,channels);
    for i=1:channels % check the flow direction (should be top to bottom)
        channelImg{i} = arrayfun(@(x) double(imread(moleculeImgPath,x)),i+(firstIdx-1)*(channels):channels:(firstIdx-1)*(channels)+max_number_of_frames*channels,'UniformOutput',false);
    end
    
%     import AB.rotate_images;
    [rotImg] = rotate_images(channelImg,movieAngle);

    clear channelImg;
%     import AB.remove_noise;
%     [rotImg] = remove_noise(rotImg, rotMask,bgSub);
    [rotImg] = remove_noise_mean(rotImg, rotMask,1,bgSub,background);

%     clear rotMask;

    
end

% molecule positions: to be improved
function [pos] = molecule_positions(kymos, statsMol, stdF,percentageNonzero,minArea,edge)

    % maybe: use widekymos instead of kymos for better position detection

    if nargin < 3
        % TODO: remove hardcoded parameters
        stdF=5;
        percentageNonzero =  0.1;
        minArea = 100;
        edge = 20;
    end
    se = strel('line',5,0); % for edge detection

    pos = [];

    avgMean = mean(cellfun(@(x) x(1),statsMol));
    avgStd = mean(cellfun(@(x) x(2),statsMol));

    map1 = zeros(size(kymos));
    for idy=1:size(kymos,1)
%         numpt2 = size(kymos,2);
        map1(idy,:) = kymos(idy,:)>(avgMean+stdF*avgStd);  
        map1(idy,:) = imerode(imdilate( map1(idy,:),se),se);
    end

    % maybe just filter based on x direction?
    regions = bwareafilt(boolean(map1),[minArea*size(kymos,1) inf]);
    components = bwconncomp(regions);   
    
%     StartY =
    % todo: fix also for multiframe
    for idy=1:length(components.PixelIdxList)
        % find positions
        [a,b]=ind2sub(size(map1),components.PixelIdxList{idy});
        for j=1:max(a)
            pos{idy}(j,1:2) = [min(b(a==j)) max(b(a==j))];
            %% add edge px
            pos{idy}(j,1) = max(1,pos{idy}(j,1)-edge);
            pos{idy}(j,2) = min(size(kymos,2),pos{idy}(j,2)+edge);
        end
    end
    
     
    % todo: deal with multi-frame case, when the position can vary.
    % Something along lines below
%         v = ones(1,size(kymos{1,idy},2));
%         v(mean(map1) < sets.percentageNonzero) = 0;
% 
%         S=regionprops(boolean(v),'Area'); % maybe dilute a little, like in edge detection!
%         regions = bwareafilt(boolean(v),[sets.minArea inf]);
%         components = bwconncomp(regions);      
%         for idx=1:size(kymos,1)
% 
%         for i = 1:length(components.PixelIdxList)
%         centerCoords{idx,idy}(i) = mean(components.PixelIdxList{i}(1),components.PixelIdxList{i}(end));
%         %             molInfo{kymoIdx}.rightEdge = min(numpt2,components.PixelIdxList{i}(end)+edge);
%         %                     subMap = map1(:,max(1,components.PixelIdxList{i}(1)-sets.edge):min(numpt2,components.PixelIdxList{i}(end)+sets.edge));
%         %                     % first remo
%         %                     dilMask = imerode(imdilate(subMap,se),se);
%         kymo{idx,idy}{i} = kymos{idx,idy}(:,max(1,components.PixelIdxList{i}(1)-sets.edge):min(numpt2,components.PixelIdxList{i}(end)+sets.edge));
%         %                     ampMask = ampfun(kymo{idx,idy}{i});
%         %                     mask =ampMask>multithresh(ampMask);
%         %                     imdilate(imerode(
%         %                     mask = imerode(imdilate(ampMask>multithresh(ampMask),se),se);
%         kymoDotsW{idx,idy}{i} = wideKymosDots{idx,idy}(max(1,components.PixelIdxList{i}(1)-sets.edge):min(numpt2,components.PixelIdxList{i}(end)+sets.edge),:,:);
%         kymNames{idx,idy}{i} = strcat(['CH' num2str(idx) '_' 'col' num2str(idy) 'b' num2str(i)]); 
%         end
%         end

%         end
            
end


function posY = find_positions_in_nanochannel(noiseKymos,kymos,posYcenter, bgSigma,filterS )

    if nargin < 4
        bgSigma = 4;
        filterS = [5 15];
    end
    
    % TODO: more accurate?
%     threshval = mean(cellfun(@(x) nanmean(x(:)), noiseKymos{1}));%+ 3*nanstd(noiseKymos{1}{1}(:));
%     threshstd = mean(cellfun(@(x) nanstd(x(:)), noiseKymos{1}));%+ 3*nanstd(noiseKymos{1}{1}(:));

    threshval = nanmean(cellfun(@(x) nanmean(medfilt2(x,filterS,'symmetric'),[1 2]), noiseKymos{1}));%+ 3*nanstd(noiseKymos{1}{1}(:));
    threshstd = nanmean(cellfun(@(x) nanstd(medfilt2(x,filterS,'symmetric'),0, [1 2]), noiseKymos{1}));%+ 3*nanstd(noiseKymos{1}{1}(:));

% medfilt2(kymos{1}{i},filterS,'symmetric')
%     threshval = mean(cellfun(@(x) nanmean(reshape(cell2mat(x),1,[])), noiseKymos{1}));%+ 3*nanstd(noiseKymos{1}{1}(:));

    posY = []; % put into function! medfilt based edge detection. Less accurate for single-frame stuff
    for i=1:length(kymos{1})
        kymos{1}{i}(isnan(kymos{1}{i}))=0;
        K = medfilt2(kymos{1}{i},filterS,'symmetric') > threshval+bgSigma*threshstd;
%         figure,imagesc(K)

        [labeledImage, numBlobs] = bwlabel(K);
         
        if ~isempty(posYcenter)
            largestIndex = labeledImage(1,round(mean(posYcenter(i,:))));
            if largestIndex == 0;
                posY{i} = [];
                continue;
            end
        else
            props = regionprops(labeledImage, 'Area');
            [maxArea, largestIndex] = max([props.Area]);
        end
        
        try
            labK = labeledImage==largestIndex; % either just max or create a loop here

            posY{i}.leftEdgeIdxs = arrayfun(@(x) find(labK(x,:) >0,1,'first'),1:size(labK,1));
            posY{i}.rightEdgeIdxs = arrayfun(@(x) find(labK(x,:) >0,1,'last'),1:size(labK,1)); 
        catch
           posY{i} = [];
        end
    end
end
    
function [posX,posY,kymos,wideKymos] = remove_empty_channels(posX,posY,kymos,wideKymos)
    % removes empty all almost empty channels, in which it was not possible
    % to detect long enough molecule
    
    numremoved = 0;
    % remove some kymo's that failed at edge detection (for
    % development, save for improvement of code)
    for i=1:length(posY)
        emptyX = cellfun(@isempty,posY{i});
        numremoved = numremoved+sum(emptyX);
        if sum(emptyX)>0
            posX{i}(emptyX) = [];
            posY{i}(emptyX) = [];
            for ch=1:length(kymos)
                kymos{ch}{i}(emptyX) = [];
                wideKymos{ch}{i}(emptyX) = [];
            end
        end
        for j=1:length(posY{i})
            emptyX = cellfun(@isempty,posY{i}{j});
            numremoved = numremoved+sum(emptyX);
            if sum(emptyX)>0
                disp(strcat(['removed fov=' num2str(i) ' posY=' num2str(posX{i}(j)) ' posX=' num2str(emptyX)]));
                posY{i}{j}(emptyX) = [];
                for ch=1:length(kymos)
                    kymos{ch}{i}{j}(emptyX) = [];
                    wideKymos{ch}{i}{j}(emptyX) = [];
                end
            end
        end
    end
    disp(strcat(['Removed ' num2str(numremoved) ' nanochannels where algorithm didnt find molecules' ]))
end

%%
function [kymo, kymoW, kymoNames,Length,posXOut,kymoOrig,idxOut] = extract_from_channels(kymos,kymosWide, posX, posY,channel,numPts,stdDifPos)
    
    %   Args:
    %   kymos,kymosDots,stdF,minArea,edge,meanBgs,stdBgs
    %
    %   Returns:
    %
    %   kymo,kymoDots,molInfo,kymNames
    kymo = [];
    kymoW = [];
    Length = [];
    kymoOrig = [];
    kymoNames = '';
        
    idx=1;
    posXOut=[];
    idxOut=zeros(1,length(kymos{1}));

    if ~isempty(posY)

%         kymo = cell(1,length(posY));
%         kymoW =  cell(1,length(posY));
%         kymoNames = cell(1,length(posY));
%         Length = cell(1,length(posY));
        nonemptypos = find(cellfun(@(x) ~isempty(x),posY));
        for i=nonemptypos
            if length(posY{i}.leftEdgeIdxs)==1
                stdY = 0; stdX = 0;
            else
                stdX = std(diff(posY{i}.leftEdgeIdxs));
                stdY = std(diff(posY{i}.rightEdgeIdxs));
            end
            if mean(posY{i}.rightEdgeIdxs-posY{i}.leftEdgeIdxs)>numPts && stdX < stdDifPos && stdY < stdDifPos% threshold num pixels
%                 idx = 1;
                kymo{idx} = nan(size(kymos{channel}{i}));
                kymoOrig{idx} = kymos{channel}{i};
                for j=1:length(posY{i}.rightEdgeIdxs)
                   kymo{idx}(j,posY{i}.leftEdgeIdxs(j):posY{i}.rightEdgeIdxs(j)) = zeros(1,length(posY{i}.leftEdgeIdxs(j):posY{i}.rightEdgeIdxs(j)));
                   kymo{idx}(j,posY{i}.leftEdgeIdxs(j):posY{i}.rightEdgeIdxs(j)) = kymos{channel}{i}(j,posY{i}.leftEdgeIdxs(j):posY{i}.rightEdgeIdxs(j));
                end
%                 kymo{i} = kymos(idx,posY{i}(idx,1):posY{i}(idx,2));   
%                 kmW = cellfun(@(x) x(posY{i}(idx,1):posY{i}(idx,2),:),kymosWide,'un',false);
                kymoW{idx} = kymosWide{channel}{i};
                for j=1:length(kymoW{idx})
                    kymoW{idx}{j}(1:posY{i}.leftEdgeIdxs(j)-1,:)=nan;
                    kymoW{idx}{j}(posY{i}.rightEdgeIdxs(j)+1:end,:)=nan;
                end
%             else
%                 kymo{i} = zeros(size(kymos));
%                 kymo{i} = kymos(:,min(posY{i}(:,1)):max(posY{i}(:,2)));
% %                 for idx=1:size(posY{i},1)
% %                     kymo{i}(idx,posY{i}(idx,1):posY{i}(idx,2)) = kymos(idx,posY{i}(idx,1):posY{i}(idx,2));         
%                 end
                kymoNames{idx} = strcat(['kymo_posX_' num2str(posX) '_startY_' num2str(mean(posY{i}.leftEdgeIdxs)) '_endY_' num2str(mean(posY{i}.rightEdgeIdxs)) ]);
                Length{idx} = mean(posY{i}.rightEdgeIdxs)-mean(posY{i}.leftEdgeIdxs)+1;
                posXOut = [posXOut posX(i)];
                
                idxOut(i)=1;
                idx = idx+1;

            end

         end
    else % this should not be required
        kymo = [];
        kymoW = [];
        Length = [];
        posXOut = [];
        kymoOrig = [];
        idxOut = [];
        kymoNames = '';
    end
    
end

function [moleculeStartEdgeIdxsApprox, moleculeEndEdgeIdxsApprox, mainKymoMoleculeMaskApprox] = basic_otsu_approx_main_kymo_molecule_edges(kymo, globalThreshTF, smoothingWindowLen, imcloseHalfGapLen, numThresholds, minNumThresholdsFgShouldPass)
    % BASIC_OTSU_APPROX_MAIN_KYMO_MOLECULE_EDGES - Attempts to find the start and
    %  end indices for the main molecule in the kymograph
    %
    %  Uses Otsu's method,
    %  some morphological operations, and component analysis,
    %  to try to separate the foreground from the background and find the
    %  "main" (i.e. largest) contiguous foreground component in each row
    %  (i.e. time frame) represented in the provided kymograph
    %
    % Inputs:
    %   kymo
    %   globalThreshTF (optional, defaults to false)
    %   smoothingWindowLen (optional, defaults to 1)
    %   imcloseHalfGapLen (optional, defaults to 0)
    %   numThresholds (optional, defaults to 1)
    %   minNumThresholdsFgShouldPass (optional, defaults to 1)
    %   
    % Outputs:
    %   moleculeStartEdgeIdxsApprox
    %   moleculeEndEdgeIdxsApprox
    %   mainKymoMoleculeMaskApprox
    %
    if nargin < 2
        globalThreshTF = false;
    end
    
    if nargin < 3
        smoothingWindowLen = 1;
    end

    if nargin < 4
        imcloseHalfGapLen = 0;
    end

    if nargin < 5
        numThresholds = 1;
    end

    if nargin < 6
        minNumThresholdsFgShouldPass = 1;
    end


    kymoSz = size(kymo);
    numFrames = kymoSz(1);
    numCols = kymoSz(2);
    mainKymoMoleculeMaskApprox = false(kymoSz);
    kymoSmooth = kymo;
    if smoothingWindowLen > 1
        kymoSmooth = conv2(kymoSmooth, ones(1, smoothingWindowLen)/smoothingWindowLen, 'same');
    end
    if globalThreshTF
        thresholdsArr = multithresh(kymoSmooth(:), numThresholds);
        fgMask = kymoSmooth >= thresholdsArr(minNumThresholdsFgShouldPass);
    else
        fgMask = false(size(kymoSmooth));
        for frameNum = 1:numFrames
            kymoSmoothRow = kymoSmooth(frameNum, :);
            thresholdsArr = multithresh(kymoSmoothRow, numThresholds);
            fgMask(frameNum, :) = kymoSmooth(frameNum, :) >= thresholdsArr(minNumThresholdsFgShouldPass);
        end
    end
    
    ccFg = bwconncomp(fgMask);
    [rowIdxLists, colIdxLists] = cellfun(@(pixelIdxList) ind2sub(ccFg.ImageSize, pixelIdxList), ccFg.PixelIdxList, 'UniformOutput', false);
    
    touchesEdgeMask = cellfun(@(colIdxList) any(colIdxList == 1) | any(colIdxList == ccFg.ImageSize(2)), colIdxLists);
    if not(all(touchesEdgeMask)) % remove all connected components that touch edges (run out of field of view), unless everything touches edges
        ccFg.PixelIdxList = ccFg.PixelIdxList(~touchesEdgeMask);
        ccFg.NumObjects = sum(~touchesEdgeMask);
        fgMask = false(ccFg.ImageSize);
        for objectIdx = 1:ccFg.NumObjects
            fgMask(ccFg.PixelIdxList{objectIdx}) = true;
        end
    end
    
    % does not do anything?
    if imcloseHalfGapLen > 0
        imcloseNhood = true(1, 1 + 2*imcloseHalfGapLen);
        % Remove small gaps
        fgMask = imclose(fgMask, imcloseNhood);
        ccFg = bwconncomp(fgMask);
    end
    [~, tmp_so] = sort(cellfun(@length, ccFg.PixelIdxList), 'descend');
    ccFg.PixelIdxList = ccFg.PixelIdxList(tmp_so);
    [rowIdxLists, colIdxLists] = cellfun(@(pixelIdxList) ind2sub(ccFg.ImageSize, pixelIdxList), ccFg.PixelIdxList, 'UniformOutput', false);
    
    % Pick the largest molecule that includes the center column
    mainKymoMoleculeMaskApprox = false(ccFg.ImageSize);
    idx = 1;
    crossesCenterColIdxTF = false;
    while idx <= ccFg.NumObjects
        crossesCenterColIdxTF = (min(colIdxLists{idx}) <= numCols/2) && (max(colIdxLists{idx}) >= numCols/2);
        if crossesCenterColIdxTF
            mainKymoMoleculeMaskApprox(ccFg.PixelIdxList{idx}) = true;
            break;
        end
        idx = idx + 1;
    end
    if not(crossesCenterColIdxTF) && (ccFg.NumObjects > 0) % if nothing crosses center column, just pick the biggest molecule
        idx = 1;
        mainKymoMoleculeMaskApprox(ccFg.PixelIdxList{idx}) = true;
    end
    
    frameNums = (1:numFrames)';
    
    unemptyRows = arrayfun(@(frameNum) any(mainKymoMoleculeMaskApprox(frameNum, :)), frameNums);
    moleculeStartEdgeIdxsApprox = NaN(numFrames, 1);
    moleculeEndEdgeIdxsApprox = NaN(numFrames, 1);
    moleculeStartEdgeIdxsApprox(unemptyRows) = arrayfun(@(frameNum) find(mainKymoMoleculeMaskApprox(frameNum, :), 1, 'first'), frameNums(unemptyRows));
    moleculeEndEdgeIdxsApprox(unemptyRows) = arrayfun(@(frameNum) find(mainKymoMoleculeMaskApprox(frameNum, :), 1, 'last'), frameNums(unemptyRows));
end

function plot_result(channelImg,rotImg,rotImgDenoise,peaksToPlot,posMax)
    % plots hpfl extract result figure
%     %figure1: original image, rotated image, rotated image - noise
    f=figure('Position', [100, 100, 600, 300])
    tiledlayout(2,2,'TileSpacing','Compact','padding','compact')
    ax1=nexttile
    imagesc(channelImg{1}{1})
    if length(channelImg)>1
        nexttile
        imagesc(channelImg{2}{1})
    end
    ax2=nexttile
    imagesc(rotImg{1}{1})
%         xlim([0 400])

    if length(channelImg)>1
        nexttile
        imagesc(rotImg{2}{1})
    end
%     xlim([0 400])
    ax3 =nexttile
    imagesc(rotImgDenoise{1}{1})
%         xlim([0 400])

    if length(channelImg)>1
        nexttile
        imagesc(rotImgDenoise{2}{1})
    end
%     xlim([0 400])
    ax4=nexttile
%     rotImgDenoise{1}{1}(rotImgDenoise{1}{1}==0)=nan
    imagesc(rotImgDenoise{1}{1})
    hold on
    for idd = 1:length(peaksToPlot)
        plot(repmat(peaksToPlot(idd),1,size(rotImgDenoise{1}{1},1)),1:size(rotImgDenoise{1}{1},1),'red')
        text(peaksToPlot(idd),-5,num2str(idd),'fontsize',5);
    end
	plot(peaksToPlot,posMax,'greenx')
    if   length(channelImg)>1
        nexttile
    %     rotImgDenoise{1}{1}(rotImgDenoise{1}{1}==0)=nan
        imagesc(rotImgDenoise{2}{1})
            hold on
        for idd = 1:length(peaksToPlot)
            plot(repmat(peaksToPlot(idd),1,size(rotImgDenoise{1}{1},1)),1:size(rotImgDenoise{1}{1},1),'red')
            text(peaksToPlot(idd),-5,num2str(idd),'fontsize',5);
        end
        plot(peaksToPlot,posMax,'greenx')
    end
%     saveas(f,fullfile('/home/albyback/git/hpflpaper/figsbin/','hpflodm1.eps'),'epsc')
    linkaxes([ax1 ax2 ax3 ax4])
end
%% rewritten:

function visual_mean(img)

figure
tiledlayout(2,2)
ax1=nexttile
plot(nanmean(img))
xlim([0 size(img,2)])
ax2= nexttile
plot(nanmean(img'))
xlim([0 size(img,1)])

ax3=nexttile
imagesc(img)
xlim([0 size(img,2)])

ax4=nexttile
imagesc(img')
xlim([0 size(img,1)])

end


function [posXlambda,posYlambda,posMax] = find_short_molecules(meanRotatedDenoisedMovieFrame,sets )
        optics.logSigma = sets.psfnm / sets.nmPerPixel;
        n = ceil(6 * optics.logSigma);
        n = n + 1 -mod(n, 2);
        filt = fspecial('log', n, optics.logSigma);
        logim = imfilter(meanRotatedDenoisedMovieFrame, filt);

        thedges = imbinarize(logim, 0);
        thedges(1:end,[ 1 end]) = 1; % things around the boundary should also be considered
        thedges([ 1 end],1:end) = 1;

        [B, L] = bwboundaries(thedges, 'holes');

        [~, Gdir] = imgradient(logim);
        stat = @(h) mean(h); % This should perhaps be given from the outside
        meh = zeros(1, length(B));

        for k = 1:length(B)% Filter out any regions with artifacts in them
            meh(k) = edge_score(B{k}, logim, Gdir, 5, stat); %how many points along the gradient to take?
        end
        
        %
        acc  = zeros(1, length(B));
        l = zeros(1, length(B));
        w = zeros(1, length(B));
        for k = 1:length(B)% Filter any edges with lower scores than lim
            [acc(k),l(k),w(k)] = mol_filt(B{k}, meh(k), sets.minScoreLambda, inf, [sets.minLambdaLen sets.maxLambdaLen], [1 sets.maxLambdaWidth]); % width depends on psf
        end
        
        potLambda = find(acc==1);
        posXlambda = zeros(1,length(potLambda));
        posYlambda =  zeros(length(potLambda),2);
        posMax =  zeros(1,length(potLambda));
        for j=1:length(potLambda)
            posXlambda(j) = round(mean(B{potLambda(j)}(:,2)));
            posYlambda(j,:) = [min(B{potLambda(j)}(:,1)) max(B{potLambda(j)}(:,1))];
            posMax(j) = round(mean(posYlambda(j,:)));            
        end
        
        
        % now save posX and posY of these molecules.
        
%             acc = mol_filt(B{k}, meh(k), lowLim, highLim, elim, ratlim, lengthLims, widthLims);


end

function score = edge_score(B,im,Gdir,dist,stat)

    bound = B;
    h = zeros(1,size(bound,1));
    for point = 1:size(bound,1)
      dir = Gdir(bound(point,1),bound(point,2)); % test to see if dirs were switched
      dx = cosd(dir); %magnus' way
      dy = -sind(dir); %magnus' way
      xser = round((-dist:1:dist)*dx) + bound(point,2);
      yser = round((-dist:1:dist)*dy) + bound(point,1);
      prof = zeros(1,2*dist+1);
      if min(min(yser),min(xser))>0 && max(xser) < size(im,2) && max(yser) < size(im,1)
        for j = 1:2*dist+1
          prof(j) = im(yser(j),xser(j));
        end
      end
      %h(point) = abs(sum(prof(1:dist))-sum(prof(dist+2:end)));
      h(point) = -sum(prof(1:dist))+sum(prof(dist+2:end));
    end

    score = stat(h);

end

function [acc,l,w] = mol_filt(B, score, lowLim, highLim, lengthLims, widthLims)
    % from SDD Dots: filters molecules
    
    % estimate length 
    l = sqrt((max(B(:,1))-min(B(:,1)))^2);
    % estimate width
    w =  sqrt( (max(B(:,2))-min(B(:,2)))^2);
    % length limits
    lOk = (l > lengthLims(1) && l < lengthLims(2));
    wOk = (w > widthLims(1) && w < widthLims(2));

    if score > lowLim && score < highLim && lOk
        acc = true;
%       [~,ecc,aRat,length,width] = cont_draw(B);
%       testofboundary = (ecc > elim && aRat > ratlim && width < widthLims(2)) ;
%       if testofboundary
%         acc = true;
%       else
%         acc = false;
%       end
    else
      acc = false;
    end
end

