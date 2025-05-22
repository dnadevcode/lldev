function [fileCells, fileMoleculeCells,kymoCells] = hpfl_extract(sets, fileCells)
    % hpfl_odm_extract / extracts molecules.
    
    % tested on:
    %
    % Movies of chromosomal DNA fragments

    % Args:
    %       sets 
    %       fileCells - precalculated data
    
    % Returns:
    %   fileCells
    %   fileMoleculeCells
    %   kymoCells - kymocells
       
    movieFilenames = sets.movies.movieNames;
    numFiles = numel(movieFilenames);

    % Go through each of the files.
    if nargin < 2
        fileCells = cell(numFiles, 1);
    end
    
    fileMoleculeCells = cell(numFiles, 1);
    params = cell(numFiles, 1); % temp storage of params for each parfor iteration

    fileStruct = struct();

    % params taken from settings and simplified calling so we don't need to
    % access fields of sets every time
    numPts = sets.numPts; % minimum length of barcode
    if sets.detectverysmall
    numPtsAboveSigmaThresh=ceil(numPts*0.5);%20
    else
    numPtsAboveSigmaThresh = sets.numPtsAboveSigmaThresh;  % number of points above meanNoise+4stdNoise for each row
    end
    averagingWindowWidth = sets.averagingWindowWidth; % averaging window width
    distbetweenChannels = sets.distbetweenChannels; % estimated distance between channels
    remNonuniform = sets.denoise;
    minLen = sets.minLen; % disable removal of mols
    stdDifPos = sets.stdDifPos;
    if sets.keepBadEdgeMols
        stdDifPos = inf;
        minLen = 0;
    end
    channels = sets.channels;
    max_f = sets.max_f;
    max_number_of_frames = sets.max_number_of_frames;
    timeframes = sets.timeframes; % number of time-frames to use to detect positions of nanochannels
    % detect columns with molecule
    farAwayShift = sets.farAwayShift; % how many rows to shift for max coefficient calculation
    channelForDistSetting = sets.channelForDist;
   
    if nargin >= 2
        usePrecalc = 1;
    else
        usePrecalc = 0;
    end

    if max_f == 0 % 0 means all frames
        max_f = inf;
    end
    import DBM4.convert_czi_to_tif;
    import DBM4.load_czi;

%     channels = [];

    % 3) load image first frame for mol detection
    tic
    % settingsHPFL.numFrames = 1;
    for idx = 1:length(movieFilenames)
        if usePrecalc
            params{idx} = fileCells{idx}.preCells;
        else
            params{idx}.name = movieFilenames{idx};
            fprintf('Importing data from: %s\n', params{idx}.name);
                          
            % load data - support multi-channel // take from the first time frame
            [ channelImg, imageData ] = load_first_frame(params{idx}.name,max_number_of_frames, max_f, channels);
            try
                firstIdx = imageData{1}.IntensityInfo.firstIdx;
            catch
                firstIdx = 1;
            end
            
%             channels = imageData{1}.info.channels;% this info already
%             passed to load first frame
%             visual_mean(channelImg{1}{1}) % visualize channel vs mean
%         figure,plot(imageData{1}.IntensityInfo.yData)

            if length(channelImg) == 1 % if single channel
                params{idx}.channelForDist = 1;
                firstIdx = 1;
            else
                params{idx}.channelForDist = channelForDistSetting;
            end

            number_of_frames = length(channelImg{1}); % maximum number of frames
            
            %
%             disp(strcat(['Image loaded in ' num2str(toc) ' seconds']));
            
           params{idx}.meanMovieFrame = mean(cat(3, channelImg{1}{:}), 3, 'omitnan');
            [rotImg, rotMask, params{idx}.movieAngle,params{idx}.maxCol] = image_rotation(channelImg, params{idx}.meanMovieFrame, sets);
%             disp(strcat(['Rotation done in ' num2str(toc) ' seconds']));
            channelImg = [];

            % image registration: in some cases fov moves slightly, which
            [rotImg] = image_registration_simple(rotImg, sets);
%             [rotImg, tformOrig] = image_registration(rotImg, sets);
            % needs correction
      
            for kk=1:length(rotImg)
                params{idx}.meanRotatedMovieFrame{kk} = mean(cat(3, rotImg{kk}{:}), 3, 'omitnan');
            end
    
            sz = size(params{idx}.meanRotatedMovieFrame{1});
        
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

        % remove noise. this also calculates central and bg trend /instead
        % could remove based on bg images
            rotImgOrig = rotImg;
            %     [rotImg,centralTend,bgTrend,bgSub] = remove_noise(rotImg, rotMask);
            [rotImg, centralTend, bgTrend, bgSub,background] = remove_noise_mean(rotImg, rotMask, 1, remNonuniform);
            %visual_mean(rotImg{1}{1}) % visualize channel vs mean
    
           % now detect channels
            for ch=1:length(rotImg)
                rotImg{ch}{1}(isnan(rotImg{ch}{1}))=0;
            end
     
            params{idx}.meanRotatedDenoisedMovieFrame = mean(cat(3, rotImg{1}{:}), 3, 'omitnan');

            if sets.detectlambdas         
                %% find lambda molecules
                 [params{idx}.posY,params{idx}.posX, params{idx}.posYcoord, params{idx}.posMax,thedges,params{idx}.kymos,params{idx}.wideKymos,pxBg,bgmean,bgstd,params{idx}.posXUpd,bitmask,...
            positions, mat,params{idx}.threshval,params{idx}.threshstd, badMol,bitWithGaps,params{idx}.bgnorm] = detect_lambda_positions(params{idx}.meanRotatedDenoisedMovieFrame,...
            sets,rotImgOrig,1,channels,params{idx}.movieAngle,params{idx}.name,number_of_frames,averagingWindowWidth,rotMask,bgSub,background);
                 noiseKymos = [];

            else
                % find columns which have appropiated size molecules
                [params{idx}.posX, params{idx}.posMax,params{idx}.nonrelevantRowsFarAway] = find_mols_corr(rotImg, bgTrend, numPtsAboveSigmaThresh, numPts, params{idx}.channelForDist, 1, centralTend, farAwayShift, distbetweenChannels,timeframes );
 %length(  params{idx}.posX) % Testing
                % update positions which has at least numPts pts above 3
                % times bgTrend
                meanVal = 0;
                stdVal = bgTrend{1}; % here could use bg kymos for this
                % remove rows that don't have enough signal pixels // could use               
                numElts = find(sum(rotImg{1}{1}(:,params{idx}.posX)  > meanVal+3*stdVal) > numPts);
                params{idx}.posXUpd = params{idx}.posX(numElts);
    %params{idx}.posXUpd % Testing
                % extract single bg kymo: background has to be within +-sets.parForNoise from the
                % middle posX
                if isempty(params{idx}.posX)
                    columns = round(sz(2)/2);
                else
                    columns = max(1,params{idx}.posX(round(end/2))-sets.parForNoise): min(params{idx}.posX(round(end/2))+sets.parForNoise,sz(2));
                end
                
                [~,diffPeaks]  = min(nanmean(params{idx}.meanRotatedMovieFrame{1}(:,columns)));
                [params{idx}.noiseKymos] = create_channel_kymos_one(columns(diffPeaks),rotImgOrig,1,channels,params{idx}.movieAngle, params{idx}.name,number_of_frames,averagingWindowWidth,rotMask,bgSub,background);
          
    

    
%                 tic
                % extract elements
                [params{idx}.kymos, params{idx}.wideKymos, params{idx}.kmChanginW, params{idx}.kmChangingPos] = ...
                    create_channel_kymos_one(params{idx}.posXUpd,rotImgOrig,1,channels,params{idx}.movieAngle,params{idx}.name,number_of_frames,averagingWindowWidth,rotMask,bgSub,background);
%                 disp(strcat(['Barcodes extracted in ' num2str(toc) ' seconds']));


            % means - max should be center
%                 figure,plot(cellfun(@(x) nanmean(x,[1 2]), kmChangingPos{1}{1}))
%                 plot_result(rotImg,rotImg,rotImg,params{idx}.posXUpd,params{idx}.posMax(numElts))

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
                        % todo: check which is best for SNR/

    
                    % 
                sz = size(params{idx}.meanRotatedDenoisedMovieFrame);
                try
                    [params{idx}.posY] = find_positions_in_nanochannel(params{idx}.noiseKymos,params{idx}.kymos,[],sz,sets.SigmaLambdaDet,sets.filterS );
                    params{idx}.posYcoord = ones(length(params{idx}.posY),2);
                catch
                    params{idx}.posY = [];
                    params{idx}.posYcoord =[];
                end
    
                % mean & std - used for SNR
                try
                    params{idx}.threshval = nanmedian(params{idx}.noiseKymos{1}{params{idx}.channelForDist}(:));
                    params{idx}.threshstd = iqr(params{idx}.noiseKymos{1}{params{idx}.channelForDist}(:));
                    params{idx}.bgnorm = nan; % todo calculate for this method too
                catch
                    params{idx}.threshval = nan;
                    params{idx}.threshstd = nan;
                    params{idx}.bgnorm = nan;
                end
            end
 
        end
    %% re-saving of these structures based on "nicity" i.e. by filtering could be re-done from here
    fileCells{idx}.preCells = params{idx};
    
    % now final step is to extract "nice" kymographs
    [params{idx}.kymo, params{idx}.kymoW, params{idx}.kymoNames, params{idx}.Length,~, params{idx}.kymoOrig, params{idx}.idxOut] =...
        extract_from_channels(params{idx}.kymos, params{idx}.wideKymos, params{idx}.posXUpd, params{idx}.posY, params{idx}.channelForDist, minLen, stdDifPos);
    %length(params{idx}.kymo)%
    if channels > 1 % in case of two channels
        [~, ~, ~, ~,~, params{idx}.kymoOrigDots] = extract_from_channels(params{idx}.kymos, params{idx}.wideKymos, params{idx}.posXUpd, params{idx}.posY, 2, minLen, stdDifPos);
        try
            [~, ~, ~, ~,~, params{idx}.kymoOrigDots3] = extract_from_channels(params{idx}.kymos, params{idx}.wideKymos, params{idx}.posXUpd, params{idx}.posY, 3, minLen, stdDifPos);
        catch
        end

    else
        params{idx}.kymoOrigDots = [];
    end
    numRemovedKymos = length(params{idx}.kymos{1})-length(params{idx}.kymo);
    if numRemovedKymos > 0
        disp(strcat(['Removed ' num2str(numRemovedKymos) ' due to minLen & stdDifPos constraint']));
    end

	params{idx}.posY = params{idx}.posY(find(params{idx}.idxOut));
    params{idx}.posYcoord = params{idx}.posYcoord((find(params{idx}.idxOut)),:);
    numMoleculesDetected=length(params{idx}.kymo);
    moleculeStructs = cell(1,numMoleculesDetected);

    for i=1:numMoleculesDetected
        moleculeStructs{i}.miniRotatedMovie = params{idx}.kymoW{i}{1};
        moleculeStructs{i}.kymograph = params{idx}.kymoOrig{i};
        if channels > 1 % in case of two channels
            moleculeStructs{i}.kymographDots = params{idx}.kymoOrigDots{i};
        end

        moleculeStructs{i}.kymosMoleculeLeftEdgeIdxs = params{idx}.posY{i}.leftEdgeIdxs;
        moleculeStructs{i}.kymosMoleculeRightEdgeIdxs = params{idx}.posY{i}.rightEdgeIdxs;

        moleculeStructs{i}.moleculeMasks = ~isnan(params{idx}.kymo{i});
        moleculeStructs{i}.rawKymoFileIdxs = i;
        moleculeStructs{i}.rawKymoFileMoleculeIdxs = i;

        try
             moleculeStructs{i}.threshval = params{idx}.threshval;
             moleculeStructs{i}.threshstd = params{idx}.threshstd;
             moleculeStructs{i}.bgnorm = params{idx}.bgnorm;

             moleculeStructs{i}.snrValues = Core.barcodes_snr(moleculeStructs{i}.kymograph, moleculeStructs{i}.moleculeMasks,params{idx}.threshval,params{idx}.threshstd);
        end
        % need to add some filters, i.e. is it too close to something?
        % close to the edge? etc
         moleculeStructs{i}.passesFilters = 1; % currently remove mol altogether
    end
        if ~isempty(params{idx}.posY)
            poss = cellfun(@(x) round([mean(x.leftEdgeIdxs) mean(x.rightEdgeIdxs)]),params{idx}.posY,'UniformOutput',false)';
        else
            poss = {};
        end
        rowEdgeIdxs = vertcat(poss{:});
        try
           rowEdgeIdxs = rowEdgeIdxs+ params{idx}.posYcoord(:,1)-1;
        end
        params{idx}.posXUpd2 = num2cell(params{idx}.posXUpd(find(params{idx}.idxOut)));
        colCenterIdxs = vertcat(params{idx}.posXUpd2{:});
        
        fileCells{idx}.fileName = params{idx}.name;
        fileCells{idx}.averagedImg = params{idx}.meanRotatedMovieFrame;
        fileCells{idx}.meanStd = [nanmean(params{idx}.meanRotatedMovieFrame{1}(:)) nanstd(params{idx}.meanRotatedMovieFrame{1}(:))];
        fileCells{idx}.locs = colCenterIdxs;
        fileCells{idx}.regions = rowEdgeIdxs;
%         fileStruct.locsRejected = colCenterIdxsRejected; % rejected regions
%         fileStruct.regionsRejected = rowEdgeIdxsRejected;
        fileCells{idx}.angleCor = params{idx}.maxCol;
        fileMoleculeCells{idx} = moleculeStructs;
%         fileCells{idx} = fileStruct;
          
    end
    disp(strcat(['All molecules extracted in ' num2str(toc) ' seconds']));


    % save kymos into single structure
    kymoCells = [];
    kymoCells.rawKymos = [];
    kymoCells.rawKymosDots = [];

    kymoCells.rawBitmask = [];
    kymoCells.kymosMoleculeLeftEdgeIdxs = [];
    kymoCells.kymosMoleculeRightEdgeIdxs = [];

    kymoCells.rawKymoFileIdxs = [];
    kymoCells.rawKymoFileMoleculeIdxs = [];
    kymoCells.rawKymoName = [];
    kymoCells.rawBitmaskName = [];
    kymoCells.enhanced = [];
    kymoCells.enhancedName = [];
    kymoCells.threshval = []; % for threshval (Bg mean)
    kymoCells.threshstd = [];
    kymoCells.bgnorm = [];
    kymoCells.snrValues = [];

    for rawMovieIdx=1:length(fileMoleculeCells)
        numRawKymos = length(fileMoleculeCells{rawMovieIdx});
        for rawKymoNum = 1:numRawKymos
            [~, srcFilenameNoExt, ~] = fileparts(movieFilenames{rawMovieIdx});
            kymoCells.rawKymos{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.kymograph;
            if channels > 1
                kymoCells.rawKymosDots{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.kymographDots;
            end

            kymoCells.rawBitmask{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.moleculeMasks;
            try
                kymoCells.threshval{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.threshval;
                kymoCells.threshstd{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.threshstd;
                kymoCells.bgnorm{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.bgnorm;

                kymoCells.snrValues{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.snrValues;
            end

            % enhanced
            sampIm = mat2gray( kymoCells.rawKymos{end});
            minInt = min(sampIm(:));
            medInt = median(sampIm(:));
%             maxInt = max(sampIm(:));
            try
                J = imadjust(sampIm,[minInt 4*medInt]);
            catch
                J =  imadjust(sampIm,[0.1 0.9]);
            end
            kymoCells.enhanced{end+1} = J;

            kymoCells.kymosMoleculeLeftEdgeIdxs{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.kymosMoleculeLeftEdgeIdxs;
            kymoCells.kymosMoleculeRightEdgeIdxs{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.kymosMoleculeRightEdgeIdxs;

            kymoCells.rawKymoFileIdxs(end+1) = rawMovieIdx;
            kymoCells.rawKymoFileMoleculeIdxs(end+1) = rawKymoNum;
            kymoCells.rawKymoName{end+1} = sprintf('%s_molecule_%d_kymograph.tif', srcFilenameNoExt, rawKymoNum);
            kymoCells.rawBitmaskName{end+1} =  sprintf('%s_molecule_%d_bitmask.tif', srcFilenameNoExt, rawKymoNum);
            kymoCells.enhancedName{end+1} =  sprintf('%s_molecule_%d_enhanced.tif', srcFilenameNoExt, rawKymoNum);

        end
    end

    
    assignin('base','fileStructOut',fileStruct);
    assignin('base','kymoCellsOut',kymoCells);

end

function [posY,posX, posYcoord, posMax,thedges,kymos,wideKymos,pxBg,bgmean,bgstd,posXUpd,bitmask,...
    positions, mat,threshval,threshstd, badMol,bitWithGaps,bgnorm]= detect_lambda_positions(meanRotatedDenoisedMovieFrame,sets,rotImgOrig,firstIdx,channels,movieAngle,name,number_of_frames,averagingWindowWidth,rotMask,bgSub,background)
    %    Args:
    
    %   Returns
    %    posY,posX, posYcoord, posMax,thedges,kymos,wideKymos,pxBg,bgmean,bgstd,posXUpd,bitmask,...
    %     positions, mat,threshval,threshstd, badMol,bitWithGaps// todo:
    %     not all used, so can keep some inside this loop
    
%             [posX,posYcenter,posMax] = find_short_molecules(rotImg{1}{1},sets );
            tic
            [posX, posYcoord, posMax,thedges] = find_short_molecules(meanRotatedDenoisedMovieFrame,sets );
            disp(strcat(['Molecules found in ' num2str(toc) ' seconds']));
            
    
            
            % calculate mean and standard deviation
%             threshval = nanmean(medfilt2(cell2mat(pxBg(:)),filterS,'symmetric'));
%             threshstd = nanstd(medfilt2(cell2mat(pxBg(:)),filterS,'symmetric'));


            % fit half Gaussian to bg intensityes
            % plot detected positions
%             figure,imagesc(meanRotatedDenoisedMovieFrame)
%             hold on
%             for ii=1:length(posX)
%                 rectangle('Position',[posX(ii)-1 posYcoord(ii,1) 3   posYcoord(ii,2)-posYcoord(ii,1)+1 ]);
%                 text(posX(ii)-1, posYcoord(ii,1),num2str(ii))
%             end
%             % extract kymos at posX and posY
%             tic
%             [kymos, wideKymos, kmChanginW, kmChangingPos] = create_molecule_kymos_lambda(rotImg,posX, posY,firstIdx,channels,movieAngle,name,number_of_frames,averagingWindowWidth,rotMask,bgSub,background);
%             disp(strcat(['Kymo extraction done in ' num2str(toc) ' seconds']));

            tic
            [kymos,wideKymos] = create_molecule_kymos_lambda(rotImgOrig,posX, posYcoord,firstIdx,channels,movieAngle,name,number_of_frames,averagingWindowWidth,rotMask,bgSub,background);
            disp(strcat(['Kymo extraction done in ' num2str(toc) ' seconds']));

%             
            pxBg = cellfun(@(x) x(thedges),rotImgOrig{1},'un',false);   % calculate this  for all channels instead?/multiframes?
            bgmean = nanmean(cellfun(@(x) nanmean(x),pxBg));
            bgstd = nanmean(cellfun(@(x) nanstd(x),pxBg));
%             pxBgdeNoised = cellfun(@(x) x-mean(x(:)),pxBg,'un',false);
%             pxBgdeNoised(pxBgdeNoised<0) = 0;
            if channels==2
                pxBg = cellfun(@(x) x(thedges),rotImgOrig{2},'un',false);   % calculate this  for all channels instead?/multiframes?
% 
                bgnorm = [];

%             bgnorm = cellfun(@(x) norm(x,'fro')/length(x),pxBg);
%             bgnorm = cellfun(@(x) norm(x,'fro')/length(x),pxBg);
% 
%             meanbar = mean(reshape(pxBg{1}(randperm(length(pxBg{1}),3*30000)),[3 30000]));
%             meanbar = meanbar - mean(meanbar);
% %             meanbar(meanbar<0) = 0;
%             norm(meanbar,'fro')/length(meanbar)
            else
                bgnorm = [];
            end
%             
%             figure,tiledlayout(8,8,'TileSpacing','none','Padding','none')
%             for i=1:length(kymos{1})
%                 K = medfilt2(kymos{1}{i},[5 15],'symmetric') > bgmean+3*bgstd;
% %                 mat{i} = K;
%                 [labeledImage, numBlobs] = bwlabel(K);
%                 nexttile 
%                 imshowpair(imresize(K,[200 500]),imresize(kymos{1}{i},[200 500]), 'ColorChannels','red-cyan'  )
%                 title(num2str(i));
%             end

             disp(strcat(['Detected ' num2str(length(kymos{1})) ' molecules']));


             if sets.keepBadEdgeMols
                 Nzero = Inf;
                 N = Inf;
             else
                 Nzero = sets.Nzero;
                 N = [];
             end

            % an approach to edge detection // for images including
            % lambdas, there should be three peaks (small lambda, big
            % lambda, bg)
            import OptMap.MoleculeDetection.EdgeDetection.median_filt; % todo: change to median_filt_alt
            [bitmask, positions, mat,threshval,threshstd, badMol,bitWithGaps] = median_filt(kymos{1}, [5 15],sets.SigmaLambdaDet,bgmean,bgstd,N,Nzero);
            
%             figure,tiledlayout(8,8,'TileSpacing','none','Padding','none')
%             for i=1:length(kymos{1})
%                 nexttile 
%                 imshowpair(imresize(bitmask{i},[200 500]),imresize(kymos{1}{i},[200 500]), 'ColorChannels','red-cyan'  )
%                 title(num2str(i));
%             end
            if ~sets.keepBadEdgeMols
    
                posXUpd = posX(find(~badMol));
                posYcoord = posYcoord(find(~badMol),:);
                
                kymos{1} = kymos{1}(find(~badMol));
                if length(kymos) > 1
                    kymos{2} = kymos{2}(find(~badMol));
                end
                bitmask = bitmask(find(~badMol));
                disp(strcat(['Removed ' num2str(sum(badMol)) ' molecules due to bad/fragmented edges']));
            else
                posXUpd = posX;
                for jj=find(badMol)
                    bitmask{jj} = ones(size(kymos{1}{jj}));
                end
            end
            

            posY = cell(1,length(bitmask));
            for i=1:length(bitmask)
                posY{i}.leftEdgeIdxs = arrayfun(@(x) find(bitmask{i}(x,:) >0,1,'first'),1:size(bitmask{i},1));
                posY{i}.rightEdgeIdxs = arrayfun(@(x) find(bitmask{i}(x,:) >0,1,'last'),1:size(bitmask{i},1));       
            end
%             ix = 16;
%             figure,tiledlayout(2,1)
%             nexttile
%             imagesc(bitmask{ix})
%             nexttile
%             imagesc(kymos{1}{ix})


%             posYcenter = []; % TODO: activate posYcenter if multi-mol extraction is fixed
%             plot_result(channelImg,rotImg,rotImg,round(posX),posMax)
            % later one needs to check if same Y does not lead to dublicate
            % molecules


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

function [rotImg] = image_registration_simple(rotImg, sets)
    % image_registration - very simple transform to correct horizontal
    % flickering

    if sets.affineTransform

        % Find the indices of non-NaN values
        [row, col] = find(~isnan(rotImg{1}{1}));
        
        % Find the boundaries of the rectangle
        row_min = min(row)+1; % shift to make sure no nans
        row_max = max(row)-1;
        col_min = min(col)+1;
        col_max = max(col)-1;

        k = 10;
        
        % Extract the rectangle without NaNs
        x = double(rotImg{1}{1}(row_min:row_max, col_min:col_max));
        x = nanmean(x);
%             figure,imshowpair(rotImg{1}{1} ,rotImg{1}{50},'Scaling','joint')


        offsets = zeros(1,length(rotImg{1}));
        for i=2:length(rotImg{1})
            
            % cut out sets.overlap from both
            y = nanmean(double(rotImg{1}{i}(row_min:row_max, col_min:col_max)));

            c = xcorr(x, [y(:,end-k+1:end) y y(:,1:k)]);
            [~, index] = max(c);
            offsets(i) = length(x) - index+k;

            for j=1:length(rotImg)
                rotImg{j}{i} =  circshift(rotImg{j}{i}, [0 -offsets(i)]);
            end
        end
    end
%             figure,imshowpair(rotImg{1}{1} ,rotImg{1}{50},'Scaling','joint')


%             tform{i} = imregtform(y,x, 'translation',optimizer,metric,'InitialTransformation',tInit);
% 
%             for j=1:length(channelImg)
%                 channelImg{j}{i} =  imwarp( channelImg{j}{i},tform{i},'OutputView',imref2d(size(x)));
%             end
    %         if sets.showresults
%                 movingRegistered = imwarp(y,tform{i},'OutputView',imref2d(size(x)));
%                 figure
%                 imshowpair(x, movingRegistered,'Scaling','joint')
    %         end

end


%%{
function [channelImg,tformOrig] = image_registration(channelImg, sets)
    % image_registration - affine transformation for slightly shifted
    % images

    %   Args:
    %       channelImg - images to transform
    %       sets - settings
    %   Returns:
    %       channelImg - transformed channel images
    %       tformOrig - transformation parameters
    tformOrig = [];
    if sets.affineTransform
        [optimizer, metric] = imregconfig('monomodal');
        % We could sit an initial transformation to ease the results
        T = [1 0 0; 0 1 0; 0 0 1];
        tInit = affine2d(T);
    
        tform = cell(1,length(channelImg)-1);
        tformOrig= cell(1,length(channelImg)-1);
    
        % align everything to first
        x = double(channelImg{1}{1});
    
        tformOrig{1} = zeros(3,3);

        for i=2:length(channelImg{1})
            
            % cut out sets.overlap from both
            y = double(channelImg{1}{i});
            
            
            tform{i} = imregtform(y,x, 'translation',optimizer,metric,'InitialTransformation',tInit);

            % limit transformation to +-3 pixels
%             if tform{i}.T(3,2)< 3
%                 tform{i}.T(3,2) = 3;
%             end
% 
%             if tform{i}.T(3,1)< 3
%                 tform{i}.T(3,1) = 3;
%             end

%             tform{i}.T(3,1:2)
            for j=1:length(channelImg)
                channelImg{j}{i} =  imwarp( channelImg{j}{i},tform{i},'OutputView',imref2d(size(x)));
            end
    %         if sets.showresults
%                 movingRegistered = imwarp(y,tform{i},'OutputView',imref2d(size(x)));
%                 figure
%                 imshowpair(x, movingRegistered,'Scaling','joint')
    %         end
            
           tformOrig{i} = tform{i}.T;
           
        end
    end
end
%%}


function [rotImg, rotMask, movieAngle, maxCol] = image_rotation(channelImg, meanMovieFrame, sets)
       % image_rotation
       %
       %    Args:
       %        channelImg - movie
       %        meanMovieFrame - movie average
       %        sets - settings for rotation
       %
       %    Returns:
       %        rotImg - rotated image
       %        rotMask - rotated image mask
       %        movieAngle - movie angle
       %        maxCol - fitting function values for different angles
       %        fitted
        
    resSizeAll = sets.resSizeAll; 
    maxCol = [];
    movieAngle = sets.initialAngle;  

    if ~isfield(sets,'angleDetectionMethod')
        sets.angleDetectionMethod = 'maxcol';
    end

    if sets.moleculeAngleValidation

        switch sets.angleDetectionMethod
            case 'maxcol'
                [movieAngle, maxCol] = maxcol_angle_detection(meanMovieFrame,movieAngle, sets);
            case 'hough'
                % todo: test
                [movieAngle, maxCol] = hough_angle_detection(channelImg, mod(movieAngle,180), sets);
            otherwise
        end


    end
        
    [rotImg, rotMask] = rotate_images(channelImg, movieAngle, resSizeAll);
    
%             BW2 = edge(resizedImg,'canny');
%             
% %             consistency check.. replace as main? just detect single peak.
% %             could be wrong
%             tic % check if this proc works allways.. would significantly
% %             speed up things..
%             thetas = 90-pos;
%             [H,theta,rho] = hough(BW2,'Theta',thetas);
% 
%             peaks = houghpeaks(H,1);
%             toc
%             allAngles = 90-theta(peaks(:,2))
%             movieAngle = allAngles;

%             [H, theta, rho] = hough(BW,'Theta',90-pos);
%             P = houghpeaks(H,1,'threshold',ceil(0.3*max(H(:))));
%             lines = houghlines(BW,theta,rho,P,'FillGap',5,'MinLength',7);

            % alternative is to do hough!
%             pos(b)

% %             tic
% %             maxCol = zeros(1,length(pos));
% %             
% %             
% %             for j=1:length(pos)
% %                 rotImg = imrotate(resizedImg, -(90+pos(j)), method);
% %                 maxCol(j) = max(nanmean(rotImg));
% %             end
% %             toc
%             
%             % maybe not needed?
%             %             [movieAngle, CC, allAngles] = get_angle({{meanMovieFrame}},1,sets.maxMinorAxis, sets.tubeSize);
% 
% %             pos(pos>89) =   pos(pos>89)-180;
%             % Find the Hough information about the lines
%             pos = -2:0.01:2;
%             for j=pos
% %                 j
%                 % quicker rotation?
%                 [rotImgT, ~] = rotate_images({{meanMovieFrame}}, movieAngle+j);
%     %             meanRotatedMovieFrame = mean(cat(3, rotImg{1}{:}), 3, 'omitnan');
%                 maxCol = [maxCol max(nanmean(rotImgT{1}{1}))];
%             end
% 
% %             tic
% %             [H, theta, rho] = hough(meanMovieFrame,'Theta',pos,'RhoResolution',0.01);
% %             toc
%             maxCol = max(H);
%             [a,b] = max(maxCol);
% %             pos(b)
% %             
%             for j=pos
% %                 j
%                 % quicker rotation?
%                 [rotImgT, ~] = rotate_images({{meanMovieFrame}}, movieAngle+j);
%     %             meanRotatedMovieFrame = mean(cat(3, rotImg{1}{:}), 3, 'omitnan');
%                 maxCol = [maxCol max(nanmean(rotImgT{1}{1}))];
%             end
%             [a,b] = max(maxCol);
            
%             BW = edge(meanMovieFrame,'canny');



end
    
function [movieAngle, maxCol] = hough_angle_detection(channelImg,movieAngle,sets)
    % hough_angle_detection
    % from oldDBM

    rot = 0;
    if movieAngle == 90
        rot = 90;
        grayscaleVideo = cell2mat(permute(channelImg{1},[1,3,2])); % flip
    else
        grayscaleVideo = cell2mat(permute(channelImg{1},[3,1,2])); % flip
    end

    % minimum and maximum values of the molecule
    minVal = min(grayscaleVideo(:));
    maxVal = max(grayscaleVideo(:));
    % scale the movie to [0,1]
    
    grayscaleVideoRescaled = (grayscaleVideo - minVal)./(maxVal - minVal);
   
%     szMovieIn = size(grayscaleVideo);
    clear grayscaleVideo;
    
    % get an amplification kernel
    amplificationFilterKernel = 0.125*ones(3,3);
    amplificationFilterKernel(2,2) = 0;
    % amplify
    grayFrames = convn(grayscaleVideoRescaled, amplificationFilterKernel, 'same').*grayscaleVideoRescaled;

  % Average the intensities
    meanGrayFrame = mean(grayFrames,3);

    % Correct for uneven illumination.
    se = strel('disk', 12);
    meanGrayFrame = imtophat(meanGrayFrame, se);

    % Edge detection
    meanGrayFrameEdges = edge(meanGrayFrame);

    % Hough transform.
    [H, theta, ~] = hough(meanGrayFrameEdges, 'theta', movieAngle+[-sets.minAngle:0.01:sets.minAngle]);

    % Find the peak pt in the Hough transform.
    peak = houghpeaks(H);

    % Optimal angle obtained from Hough peaks
    movieAngle = rot+270-theta(peak(2)); %mod(theta(peak(2)), 360); %? is it correct
    maxCol = theta;


end


function [movieAngle, maxCol] = maxcol_angle_detection(meanMovieFrame,movieAngle, sets)

        npeaks = sets.npeaks;

        % optional: resize
        method = 'bilinear'; %bicubic bilinear
        resSize = 1; % put to settings


        if sets.takeSmaller
            resizedImg = meanMovieFrame(max(1,end/2-250):min(end,end/2+250),max(1,end/2-250):min(end,end/2+250));
        else
            resizedImg = meanMovieFrame;
        end

            
        sz = size(resizedImg);
        % resize images to bigger

        npeaks = max(npeaks,ceil(min(sz)/100)); 
        mpkdist = min(20,min(sz)-2);% minimum peak distance. So that taking mean would be more robust 

        %% Determine if image is rotated 90 degrees
        if sets.checkfornineteedegrees
            thet = [nanmean(findpeaks(nanmean(resizedImg'),'Npeaks',npeaks,'SortStr','descend','MinPeakDistance',mpkdist)) nanmean(findpeaks(nanmean(resizedImg),'Npeaks',npeaks,'SortStr','descend','MinPeakDistance',mpkdist))];
    
            [int,pos] = max(thet) ;
            if pos==2
                movieAngle = 90;
            else
                movieAngle = 0;
            end
        else
            movieAngle = movieAngle+90;
        end

        % TEST ANGLE DETECTION
        pos = movieAngle+[-sets.minAngle:sets.angleStep:sets.minAngle];

        resizedImg = imresize(resizedImg,  [resSize*sz(1) resSize*sz(2)], method);

        maxCol = arrayfun(@(x) sum(findpeaks(nanmean(imrotate(resizedImg, -(90+x), method)),'Npeaks',npeaks,'SortStr','descend','MinPeakDistance',mpkdist)),pos);

        [a,b] = max(maxCol);
        movieAngle =  pos(b); % best angle
end

% function to load the first frame
function [channelImg, imageData] = load_first_frame(moleculeImgPath, max_number_of_frames,numFrames,channels)
    % for irys data

        

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
    

    [beg,mid,ending] =  fileparts(moleculeImgPath); % todo: move outside since can be multiple files

    if isequal(ending,'.mat') % load all frames
        load(moleculeImgPath);
        return;
    end
    if isequal(ending,'.czi') % load all frames
        import DBM4.load_czi;
        [channelImg,imageData] = load_czi(moleculeImgPath, max_number_of_frames, channels);
    else
    


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
    numFrames = min(numFrames,maxFr/channels-firstIdx+1);
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
function [channelImg,rotMask] = rotate_images(channelImg,movieAngle,resSize)

    if nargin < 3
        resSize = 5;
    end
    % rotate image. do proper interpolation
    sz = size(channelImg{1}{1});
%     interpimg = imresize(channelImg{1}{1}{1}, [5*sz(1) 5*sz(2)], 'bilinear');
%     rotim = imrotate(double(interpimg), -(90+movieAngle), 'bilinear');
%     rotimUpd = imresize(rotim,[max(sz) min(sz)]);% get proper size..
    
    method = 'bilinear'; %bicubic

    if resSize > 1
        % resize images to bigger
    %     tic
        channelImg = cellfun(@(y) cellfun(@(z) ...
                imresize(double(z),  [resSize*sz(1) resSize*sz(2)], method), y, 'un',false),channelImg,'un',false);
        % rotate image
    end
    
    % memory efficient rotation
    for ii=1:length(channelImg)
        for jj=1:length(channelImg{ii})
            channelImg{ii}{jj} =  imrotate(double(channelImg{ii}{jj}), -(90+movieAngle), method);
        end
    end

%     % previously
%     rotImg = cellfun(@(y) cellfun(@(z) ...
%         imrotate(double(z), -(90+movieAngle), method), y, 'un',false),channelImg,'un',false);
% 
        sz2 = size(channelImg{1}{1});

    if resSize > 1
        % resize back to smaller.
        channelImg = cellfun(@(y) cellfun(@(z) ...
            imresize(double(z),  [round(sz2(1)/resSize) round(sz2(2)/resSize)], method), y, 'un',false),channelImg,'un',false);
    end
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
            for i=1:length(channelImg)
                for k=1:length(channelImg{i})
                    channelImg{i}{k}(rotMask) = nan;
                    channelImg{i}{k}(:,nonzeronum<maxsum) = nan; % remove columns with few pixels to get rid of edge effects
                end
            end
        end

end

function [rotImg, meanTrend, bgTrend, firstMeanPrediction,background] = remove_noise_mean(rotImg, rotMask,firstIdx, remNonuniform,firstMeanPrediction,background)
 
    % Args:
    %   rotImg, rotMask
    %
    %   Returns:
    %       rotImg - rotated image
    %       meanTrend - trend of the mean
    %       bgTrend - std deviation
    %       firstMeanPrediction

        if nargin >=5
            for i=1:length(rotImg)
                for k=1:length(rotImg{i})
                    rotImg{i}{k}(rotMask) = nan;
                    if remNonuniform
                        rotImg{i}{k} =  rotImg{i}{k}-firstMeanPrediction(i)-background{i};
                    else
                        rotImg{i}{k} =  rotImg{i}{k}-firstMeanPrediction(i);
                    end
%                     rotImg{i}{k}(rotImg{i}{k} < 0 ) = nan;
                end
            end
        else
   
        if remNonuniform==1
            for ii=1:length(rotImg) % iterate through different fields of view.
                se = strel('disk',15);
%                 se = strel('rectangle',[100 20]);
                imgtest = rotImg{ii}{firstIdx};
                imgtest(isnan(imgtest)) = nanmin(imgtest(:));

                background{ii} = imopen(imgtest,se);
                background{ii}(rotMask) = nan;  
            end
        else
            for ii=1:length(rotImg) 
                background{ii} = 0;
            end
        end

        for ii=1:length(rotImg) % iterate through different fields of view.
        % temporary signal frame
            if remNonuniform==1
                tmp = rotImg{ii}{firstIdx}-background{ii};
            else
                tmp = rotImg{ii}{firstIdx};
            end

            tmp(rotMask) = nan;
            nnztmp  = tmp(tmp~=0);
            
            firstMeanPrediction(ii) = nanmean(nnztmp);
            bgTrend{ii} = nanstd(nnztmp(nnztmp<firstMeanPrediction(ii)));
        
            signalPoints = nnztmp(nnztmp>firstMeanPrediction(ii)+4*bgTrend{ii});
        
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

function [posX, posMax,nonrelevantColumnsFarAway] = find_mols_corr(rotImg,bgTrend,numPtsAboveSigmaThresh, numPts,channelForDist,firstIdx,centralTend,farAwayShift, distbetweenChannels,timeframes);
        %   Args:
        %
        %   Returns:
        %       posX - column indexes
        %       posmax - max in that column
        %       nonrelevantRowsFarAway - non-relevant rows

        % Step 1: which columns pass numPtsAboveSigmaThresh ?
        meanVal = 0;
        stdVal = bgTrend{channelForDist};
        signalColumns = sum(rotImg{1}{firstIdx}  > meanVal+4*stdVal) > numPtsAboveSigmaThresh;
        bacgroundColumns = 1:size(rotImg{1}{firstIdx},2);
        bacgroundColumns(signalColumns)=0;
        
        % these will be mostly noise rows
        nonrelevantColumnsFarAway = find(sum(rotImg{1}{firstIdx}  > meanVal+4*stdVal) < numPtsAboveSigmaThresh); % todo: what if everything has signal?
        faraway = cell(1,2); % far away cells
        faraway{1} =  rotImg{1}{firstIdx}(:, nonrelevantColumnsFarAway);
        faraway{2} = circshift(faraway{1},[0,1]);
        faraway{1}(:,1:8) = nan; % mask first and last columns
        faraway{1}(:,end-7:end) = nan;

        for ch=1:length(rotImg)
            rotImg{ch}{firstIdx}(:,find(bacgroundColumns))=nan;%min(rotImg{2}{1}(:));
        end
        % Now find molecules..
        
        % first we find the far-away shift
        try
            [maxFirst, posFirst] = max(faraway{1});        
            corrsFarAway = find_column_max(faraway{1},faraway{2},posFirst,numPts);
        catch
            corrsFarAway = nan;
        end      

        tic
        % import AB.find_molecules;      %  1:settingsHPFL.numFrames
        [height, posX, peakMat, peaksToPlot, peakcc, peakint,corrM,posMax] =  ...
            find_molecules({rotImg{channelForDist}{firstIdx}},numPts,centralTend{channelForDist},...
        farAwayShift, distbetweenChannels,timeframes,corrsFarAway)  ;
        disp(strcat(['Channel detection done in ' num2str(toc) ' seconds']));
end
        
    
function [height,peakpos,peakMat, peaksToPlot, peakcc,peakint,corrM,maxPos] = find_molecules(rotImg,numPts,meanSignal,...
    farAwayShift, distbetweenChannels,timeframes,corrsFarAway)
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

%     corrsFarAway = find_column_max(rotImg{1},circshift(rotImg{2},[0,farAwayShift]),posFirst,numPts);
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


function [kymos, wideKymos,kymosDifferentwidth, kymosDifferentPos] = create_molecule_kymos_lambda(rotImg,posX, posY, firstIdx,channels,movieAngle, name,number_of_frames,averagingWindowWidth,rotMask,bgSub,background)
    % create_molecule_kymos_lambda - create kymos for each of the detected
    % lambda molecules
    % assumes images already loaded and rotated in rotImg
    
    %   Args:
    
    %   Returns:
    
    
    if nargin < 2
        averagingWindowWidth = 3;
    end
   
    % for each peakpos, we create a kymo
    kymos = cell(1,length(channels));
    wideKymos = cell(1,length(channels));
    kymosDifferentPos = cell(1,length(posX));

    kymosDifferentwidth =  cell(1,length(posX));
    numSegsLeft = floor((averagingWindowWidth-1)/2);
    numSegsRight = floor(averagingWindowWidth/2);
    averagingWindowWidthMax = 5;
    
    numExtra = 5;
%     adddetail = 1;
    % if there is no setting about the details
%     if ~isfield(settings,'adddetail')
%         settings.adddetail = 1;
%     end
    
    
    % what to do if too many frames are selected, make sure this does not
    % error. This just takes average over the time frames.
    for idx=1:number_of_frames % this loop can be outside this function!
        for j=1:length(rotImg) % go through different channels. Could be a cellfun to remove the loop
            rotImg{j}{idx}(rotImg{j}{idx}==0) = nan;
            for idy=1:length(posX) % different peak positions. Could be cellfun
                % main part: take some segs left and some right
                img = rotImg{j}{idx}(max(posY(idy,1)-numExtra,1):min(posY(idy,2)+numExtra,end),max(1,posX(idy)-numSegsLeft):min(end,posX(idy)+numSegsRight));% should also write out how many rows we took in case not all..
                img(img==0)=nan;
                kymos{j}{idy}(idx,:) =  nanmean(img,2); 
                        
                if nargout >= 2
                    wideKymos{j}{idy}{idx} = img;
                    %% extra.. first create kymographs for different averaging window widths

                    for k =1:averagingWindowWidthMax
                        numSegsLeftT = floor((k-1)/2);
                        numSegsRightT = floor(k/2);
                        img = rotImg{j}{idx}(max(posY(idy,1)-numExtra,1):min(posY(idy,2)+numExtra,end),max(1,posX(idy)-numSegsLeftT):min(end,posX(idy)+numSegsRightT));
                        kymosDifferentwidth{idy}{j}{k}(idx,:) =  nanmean(img,2); 
                    end

                    for k =-averagingWindowWidthMax:averagingWindowWidthMax
                        img = rotImg{j}{idx}(max(posY(idy,1)-numExtra,1):min(posY(idy,2)+numExtra,end),max(1,posX(idy)+k):min(end,posX(idy)+k));

                        kymosDifferentPos{idy}{j}{k+averagingWindowWidthMax+1}(idx,:) =  nanmean(img,2); 

                    end
                end                
            end
        end
    end
end


function [kymos, wideKymos,kymosDifferentwidth, kymosDifferentPos] = create_channel_kymos_one(peakpos,rotImg, firstIdx,channels,movieAngle, name,max_number_of_frames,averagingWindowWidth,rotMask,bgSub,background)
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
    for idx=firstIdx:max_number_of_frames % this loop can be outside this function!
       try
           % load image. Important, this rotates & also removes backgroun
%            rotImg = load_rot_img(name,firstIdx+idx-1,channels,movieAngle,1,rotMask,bgSub,background);
            for j=1:length(rotImg) % go through different channels. Could be a cellfun to remove the loop
%                 rotImg{j}{1}(rotImg{j}{1}==0) = nan;
                    for idy=1:length(peakpos) % different peak positions. Could be cellfun
                        % main part: take some segs left and some right
                        img = rotImg{j}{idx}(:,max(1,peakpos(idy)-numSegsLeft):min(end,peakpos(idy)+numSegsRight),:);% should also write out how many rows we took in case not all..
                        img(img==0)=nan;
                        kymos{j}{idy}(idx-firstIdx+1,:) =  nanmean(img,2); 
                        
                        if adddetail
                            wideKymos{j}{idy}{idx-firstIdx+1} = img;
                            %% extra.. first create kymographs for different averaging window widths

                            for k =1:averagingWindowWidthMax
                                numSegsLeftT = floor((k-1)/2);
                                numSegsRightT = floor(k/2);
                                img = rotImg{j}{idx-firstIdx+1}(:,max(1,peakpos(idy)-numSegsLeftT):min(end,peakpos(idy)+numSegsRightT),:);
                                kymosDifferentwidth{idy}{j}{k}(idx-firstIdx+1,:) =  nanmean(img,2); 

                            end

                            for k =-averagingWindowWidthMax:averagingWindowWidthMax
                                img = rotImg{j}{idx-firstIdx+1}(:,max(1,peakpos(idy)+k):min(end,peakpos(idy)+k),:);

                                kymosDifferentPos{idy}{j}{k+averagingWindowWidthMax+1}(idx-firstIdx+1,:) =  nanmean(img,2); 

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


function [posY,threshval,threshstd] = find_positions_in_nanochannel(noiseKymos,kymos,posYcenter,sz, bgSigma,filterS )

    if nargin < 5
        bgSigma = 4;
        filterS = [5 15];
    end
    
%     if ~isempty(sz)
%         mask = zeros(sz(1), sz(2));
%     end
    % TODO: more accurate?
%     threshval = mean(cellfun(@(x) nanmean(x(:)), noiseKymos{1}));%+ 3*nanstd(noiseKymos{1}{1}(:));
%     threshstd = mean(cellfun(@(x) nanstd(x(:)), noiseKymos{1}));%+ 3*nanstd(noiseKymos{1}{1}(:));

    threshval = max(0,nanmean(cellfun(@(x) nanmean(medfilt2(x,filterS,'symmetric'),[1 2]), noiseKymos{1})));%+ 3*nanstd(noiseKymos{1}{1}(:));
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
        
        % todo: fix/remove fragmented images
        try
            labK = labeledImage==largestIndex; % either just max or create a loop here
%             mask2 = zeros(sz(1),sz(2));
%             if sum(mask.*labK,'all') == 0 % check if molecule repeats/overlaps
                posY{i}.leftEdgeIdxs = arrayfun(@(x) find(labK(x,:) >0,1,'first'),1:size(labK,1));
                posY{i}.rightEdgeIdxs = arrayfun(@(x) find(labK(x,:) >0,1,'last'),1:size(labK,1)); 
%                 mask(labK) = 1;
%             else
%                 posY{i} = [];
%             end
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
    % extracts from channels
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
        for i = nonemptypos
            if length(posY{i}.leftEdgeIdxs) == 1
                stdY = 0; stdX = 0;
            else
                stdX = std(diff(posY{i}.leftEdgeIdxs));
                stdY = std(diff(posY{i}.rightEdgeIdxs));
            end
            if mean(posY{i}.rightEdgeIdxs-posY{i}.leftEdgeIdxs)>numPts && stdX < stdDifPos && stdY < stdDifPos% threshold num pixels

                kymo{idx} = nan(size(kymos{channel}{i}));
                kymoOrig{idx} = kymos{channel}{i};
                for j=1:length(posY{i}.rightEdgeIdxs)
                   kymo{idx}(j,posY{i}.leftEdgeIdxs(j):posY{i}.rightEdgeIdxs(j)) = zeros(1,length(posY{i}.leftEdgeIdxs(j):posY{i}.rightEdgeIdxs(j)));
                   kymo{idx}(j,posY{i}.leftEdgeIdxs(j):posY{i}.rightEdgeIdxs(j)) = kymos{channel}{i}(j,posY{i}.leftEdgeIdxs(j):posY{i}.rightEdgeIdxs(j));
                end

                kymoW{idx} = kymosWide{channel}{i};
                for j=1:length(kymoW{idx})
                    kymoW{idx}{j}(1:posY{i}.leftEdgeIdxs(j)-1,:)=nan;
                    kymoW{idx}{j}(posY{i}.rightEdgeIdxs(j)+1:end,:)=nan;
                end

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
%     ax1=nexttile
%     imagesc(channelImg{1}{1})
%     if length(channelImg)>1
%         nexttile
%         imagesc(channelImg{2}{1})
%     end
%     ax2=nexttile
%     imagesc(rotImg{1}{1})
% %         xlim([0 400])
% 
%     if length(channelImg)>1
%         nexttile
%         imagesc(rotImg{2}{1})
%     end
%     xlim([0 400])
%     ax3 =nexttile
%     imagesc(rotImgDenoise{1}{1})
% %         xlim([0 400])
% 
%     if length(channelImg)>1
%         nexttile
%         imagesc(rotImgDenoise{2}{1})
%     end
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
%     linkaxes([ax1 ax2 ax3 ax4])
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


function [posXlambda,posYlambda,posMax,thedges] = find_short_molecules(meanRotatedDenoisedMovieFrame,sets )
        % finds short molecules // originally from sdd_dots project
        sets.varPx = 3;
        varPx = sets.varPx;
        
        optics.logSigma = sets.psfnm / sets.nmPerPixel;
        n = ceil(6 * optics.logSigma); % estimate n
        n = n + 1 - mod(n, 2);
        filt = fspecial('log', n,  optics.logSigma);
        logim = imfilter(meanRotatedDenoisedMovieFrame, filt);

        thedges = imbinarize(logim, 0);
        
        thedges = imclose(thedges, true(ceil( optics.logSigma))); % made this dependent on logSigma
%         se1 = strel('line',3,0)
%         thedges = imdilate(thedges,se1);
%         
%         thedges(1:end,[ 1 end]) = 1; % things around the boundary should also be considered
        thedges([ 1 end],1:end) = 1;
                
        % for each feature, cut pixels deviating from the central line

        [B, L] = bwboundaries(thedges, 'holes');
        [~, Gdir] = imgradient(logim);
        % todo: score for each position based on imgradient
        
        stat = @(h) mean(h); % This should perhaps be given from the outside
        
        % filter lengths based on min and max, sets.MaxNumPts should be at
        % least 2 times the max allowed length (and a bit more since we
        % need to allow local pixel variations)
        
        % number of unique y values has to be at least sets.numPts
        longFeats = cellfun(@(x) length(unique(x(:,1))) >= sets.numPts,B);

%         longFeats = cellfun(@(x) size(x,1) >= sets.numPts,B);
        B = B(longFeats);
        
        shortFeats = cellfun(@(x) length(unique(x(:,1))) <= sets.MaxNumPts,B);
        B = B(shortFeats);

        
        % now hist of B will have two peaks
%         closedImg = imclose(B{14},strel('disk',30));
%         k =14;
    

%         [counts, binlocation] = imhist(B{14}(:,2));  %plus whatever option you used for imhist
% [sortedcount, indices] = sort(count);    %sort your histogram
% peakvalues = sortedcount(1:3)              %highest 3 count in the histogram
% peaklocations = binlocation(indices(1:3))  %respective image intensities for these peaks


        meh = zeros(1, length(B));

%         % find center
%         posX = cellfun(@(x) mean(x(:,2)),B);
%         for k = 1:length(B)% Filter out any regions with artifacts in them
% 
% 
%         end
%         

        % want to find 2 peaks, so mol has to be wide enough
        for k = 1:length(B)% Filter out any regions with artifacts in them
            [N,edges] = histcounts(B{k}(:,2));
            bcenters = (edges(2:end)+edges(1:end-1))/2;
            [Ypk,Xpk] = findpeaks([0 N 0],'SortStr','desc','Npeaks',2);
            % 
            posEdges = bcenters(Xpk-1);

            % allow a few pixs variation
            pL = min(posEdges)-varPx;  pR = max(posEdges)+varPx; % varPx depends on nmpx

            tooWide = (B{k}(:,2) < pL)+(B{k}(:,2) > pR);
            B{k}(logical(tooWide),:) = [];
            meh(k) = edge_score(B{k}, logim, Gdir, 5, stat); %how many points along the gradient to take?
        end
        
        % calculate some edge scores for random locations
        nmrand = 100;
        randMeh = zeros(1, nmrand);
        dim = size(meanRotatedDenoisedMovieFrame,[1 2]);
        for k = 1:nmrand% Filter out any regions with artifacts in them
            indices = randsample(dim(1)*dim(2),sets.numPts);
            [I J] = ind2sub(dim,indices);
            randMeh(k) = edge_score([I J], logim, Gdir, 5, stat); %how many points along the gradient to take?
        end
        
%          [sortedData ] =sort(meh,'desc','MissingPlacement','last');
         sets.minScoreLambda = mean(randMeh)+3*std(randMeh);
%          sets.minScoreLambda = mean(sortedData(1:5))-3*std(sortedData(1:5)); % 
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
      xser = round((-dist:1:dist)*dx) + bound(point,2); % dist depends a bit on nmpx!
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

    if score > lowLim && score < highLim && lOk && wOk
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

