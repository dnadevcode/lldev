function [grayscaleVideoRescaled, moleculeStructs, colCenterIdxs, rowEdgeIdxs] = detect_molecules(grayscaleVideo, settings)
    % detect_molecules - takes a tif video file (with path fname), an averaging window
    %	width (typically 3 pixels), and a noise threshold (signalAboveNoise),
    %	and finds molecules in the movies. It returns a struct for each molecule.
    %
    % Args:
    %   grayscaleVideo: grayscale video where third dimension represents timeframe
    %   settings: settings structure containing all the settings
    %
    % Returns:
    %   rotatedMovie
    %    the rotated movie
    %   miniRotatedMoviesCoords
    %    coordinate ranges in the movie for the molecules that were
    %    detected
    %   colCenterIdxs
    %     the index of the central column for each molecule in the rotated
    %     movie
    %   rowEdgeIdxs
    %     the indices of the edge rows for each molecule in the rotated
    %     movie
    %
    % Authors:
    %   Charleston Noble
    %   Albertas Dvirnas
    
    
%     averagingWindowSideExtensionWidth = floor((settings.averagingWindowWidth - 1)/2);
%     signalThreshold = settings.signalThreshold;
    rowSidePadding = settings.rowSidePadding;
    fgMaskingSettings = settings.fgMaskingSettings;
    fgMaskingSettings.rowSidePadding = rowSidePadding;
    

   
    % minimum and maximum values of the molecule
    minVal = min(grayscaleVideo(:));
    maxVal = max(grayscaleVideo(:));
    % scale the movie to [0,1]
    grayscaleVideoRescaled = (grayscaleVideo - minVal)./(maxVal - minVal);
    clear grayscaleVideo;
    
    % get an amplification kernel
    import OldDBM.MoleculeDetection.get_amplification_filter_kernel;
    amplificationFilterKernel = get_amplification_filter_kernel();
    % amplify
    amplifiedGrayscaleMovie = convn(grayscaleVideoRescaled, amplificationFilterKernel, 'same').*grayscaleVideoRescaled;

    
    if settings.rotateMovie
        % compute an angle using HOUGH transformation
        import DBM4.get_angle;
        rotationAngle = get_angle(amplifiedGrayscaleMovie);

        ninetyDegRotations = round(rotationAngle/90);
        finetunedRotation = rotationAngle - ninetyDegRotations*90;
        % ninetyDegRotations = ninetyDegRotations + 1; % Orient Channels Vertically
        ninetyDegRotations = mod(ninetyDegRotations, 4);

%         rotatedMovie = grayscaleVideoRescaled;
        grayscaleVideoRescaled = rot90(grayscaleVideoRescaled, ninetyDegRotations);
        amplifiedGrayscaleMovie = rot90(amplifiedGrayscaleMovie, ninetyDegRotations);
        szMovieIn = size(grayscaleVideoRescaled);

        if finetunedRotation ~= 0
           % warning('Movie data is being rotated via bilinear interpolation');
            bboxMode = 'crop';
            % should we have crop/loose here?
            grayscaleVideoRescaled = imrotate(grayscaleVideoRescaled, finetunedRotation, 'bilinear',bboxMode);
            amplifiedGrayscaleMovie = imrotate(amplifiedGrayscaleMovie, finetunedRotation, 'bilinear',bboxMode);
            % add zeros to the edges since bilinear interpolation does not
            % deal well with these
            c = zeros(szMovieIn(1),szMovieIn(2));
            c(2:end-1,2:end-1) = 1;

            % method for coordinate matrix should be 'nearest' to avoid artifacts
            % when doing bilinear interpolation (then between 200 and 0 there's
            % 100, while in fact it should be 0. Note that this only allows us to
            % see where there are nonzero pixels, though we can't use them to index
            % the coordinates. todo: do both
            rotationSamplingMethod = 'nearest';

            % rotate the X coordinate matrix
            segmentFrameRot = imrotate(c, finetunedRotation, rotationSamplingMethod, bboxMode);

     
            % we care only abound indices that were in original grid. These are the
            % points that have length(y)>=r>=1, length(x)>c>=1. 
            % can we find cases where extra points are denoted as non zero?
%             segmentFrameRot = (rRot >= 1) & (rRot <= szMovieIn(1)) & (cRot >= 1) & (cRot <= szMovieIn(2));

            for i=1:size(grayscaleVideoRescaled,3)
                tempImg = grayscaleVideoRescaled(:,:,i);
                tempImg(~segmentFrameRot)=0;
                grayscaleVideoRescaled(:,:,i) = tempImg;
                tempImg = amplifiedGrayscaleMovie(:,:,i);
                tempImg(~segmentFrameRot)=0;
                amplifiedGrayscaleMovie(:,:,i) =  tempImg;
            end
        end 
    end
  
    % detect channels
    fprintf('Detecting channels...\n');
%       import DBM4.find_molecule_channels;
%     [peakpos, peakcc,peakint] = find_molecule_channels(grayscaleVideoRescaled(:,:,1), settings);

%% v3
% a number of methods methods: one is considers correlation between columns. The other
% considers correlation between frames. alternative: compute correlation
% for 300? pixel window around the brightest point
tic
% settings.numPts = 200; % maybe we don't want to take the whole channel
peakposT=[];peakcc=[];peakint=[];
peakMat = zeros(size(grayscaleVideoRescaled,3),size(grayscaleVideoRescaled,2));
for i=1:size(grayscaleVideoRescaled,3)-1 % not all
    % use first image for detecting channels
      import DBM4.find_molecule_channels_v3;
    [peakposT{i}, peakcc{i},peakint{i}] = find_molecule_channels_v3(squeeze(grayscaleVideoRescaled(:,:,i:i+1)), settings);
    peakMat(i,peakposT{i}) = 1;
end
toc

%% v4
% tic
% % settings.numPts = 200; % maybe we don't want to take the whole channel
% peakposT=[];peakcc=[];peakint=[];
% meanIm = nanmean(grayscaleVideoRescaled,3);
% peakMat = zeros(size(meanIm,3),size(meanIm,2));
% for i=1:size(meanIm,3)-1 % not all
%     % use first image for detecting channels
%       import DBM4.find_molecule_channels_v4;
%     [peakposT{i}, peakcc{i},peakint{i}] = find_molecule_channels_v4(meanIm, settings);
%     peakMat(i,peakposT{i}) = 1;
% end
% toc

%% v2
%
% tic
% peakposT=[];peakcc=[];peakint=[];
% peakMat = zeros(size(grayscaleVideoRescaled,3),size(grayscaleVideoRescaled,2));
% for i=1:size(grayscaleVideoRescaled,3)-1 % not all
%     % use first image for detecting channels
%       import DBM4.find_molecule_channels_v2;
%     [peakposT{i}, peakcc{i},peakint{i}] = find_molecule_channels_v2(squeeze(grayscaleVideoRescaled(:,:,i:i+1)), settings);
%     peakMat(i,peakposT{i}) = 1;
% end
% toc
% 
%% v1
% tic
% peakposT=[];peakcc=[];peakint=[];
% peakMat = zeros(size(grayscaleVideoRescaled,3),size(grayscaleVideoRescaled,2));
% for i=1:size(grayscaleVideoRescaled,3)
%     % use first image for detecting channels
%       import DBM4.find_molecule_channels;
%     [peakposT{i}, peakcc{i},peakint{i}] = find_molecule_channels(grayscaleVideoRescaled(:,:,i), settings);
%     peakMat(i,peakposT{i}) = 1;
% end
% toc

% number of peaks
numberPeaks = sum(peakMat);
% numberPeaks = movsum(sum(peakMat),3,'Endpoints','discard' );

% there should not be any close together
[height,peakpos] = findpeaks(numberPeaks,'MinPeakHeight',min(size(grayscaleVideoRescaled,3)/4,settings.fgMaskingSettings.minMoleculeSize),'MinPeakDistance',settings.distbetweenChannels);
% find position present in at least half of the timeframes
% peakpos = find(numberPeaks>size(grayscaleVideoRescaled,3)/2);

% 
% save this as PNG:
import DBM4.plot_image_with_peaks;
f = plot_image_with_peaks(nanmean(grayscaleVideoRescaled,3),peakpos,1);
import DBM4.export_detected_channel_png;
export_detected_channel_png(f,settings)
    
%         export_dbm_session_struct_mat(dbmODW, dbmOSW, defaultOutputDirpath);

%     figure,plot(grayscaleVideoRescaled(:,peakpos(24)))
    
    % now work with channel data. 
    
    
%     
%     image = grayscaleVideoRescaled(:,1:100,1);
%        cutout = 0.01;
%     num_to_cut = ceil( numel(image) * cutout / 2);
%     sorted_data = sort(image(image~=0));
%     cmin = sorted_data( num_to_cut );
%     cmax = sorted_data( end - num_to_cut + 1);
% %     figure,imagesc(image,[cmin, cmax])
    % imagesc(data, [cmin, cmax]);
    
    % now from each channel take averagingWindowWidth. This should be even
    % for this to make most sense. otherwise we take the column closest to
    % the intensity peak
    
    % in each channel need to detect molecules..

%     settings.averagingWindowWidth=3;

    tic
    import DBM4.create_channel_kymos;
    [kymos,wideKymos] = create_channel_kymos(grayscaleVideoRescaled, peakpos, settings);
    toc
    import DBM4.export_detected_channel_as_multitif;
    export_detected_channel_as_multitif(kymos,settings)
    % could save these
    
    % now get noise profile's from non-signal channels!
    channels = zeros(1,size(grayscaleVideoRescaled,2));
    channels(peakpos) = 1;
    SE = strel('square',10);
    dilatedMask = imdilate( channels,SE)+zeros(size(grayscaleVideoRescaled));
    %todo: catch the case where mask is zeros

%     image = nanmean(grayscaleVideoRescaled,3);
        % take mean of the image
    mask = nan(size(grayscaleVideoRescaled));
    mask(logical(dilatedMask)) = 1 ;
    mask(grayscaleVideoRescaled==0) = nan ;

%     mask(mask~=1) = nan;
    rowImageNoise = nanmean(grayscaleVideoRescaled.*mask,2);
   colImageNoise = nanmean(grayscaleVideoRescaled.*mask,1);

    % maybe should smoothen this a bit for some bumps due to small signal
    % in channels?
%     denoisedgrayscale = grayscaleVideoRescaled-rowImageNoise;
%     
%        tic
%     import DBM4.create_channel_kymos;
%     [kymos2,wideKymos2] = create_channel_kymos(denoisedgrayscale, peakpos, settings);
    toc
    
%     colormap(gray)
    averagedKymos =  cellfun(@(x) nanmean(x,1),kymos,'UniformOutput',false);

    % for the average, find the positions
    
% now for each kymo, we use matrix profile to detect the correct
    % position of a fragment
%     
% tic
% detectedChannelNum =6;
%     % Correct for uneven illumination.
%     se = strel('disk', 100);
%     averagedKymos{detectedChannelNum}(isnan(averagedKymos{detectedChannelNum}))=0;
%     meanGrayFrame = imtophat(averagedKymos{detectedChannelNum}, se);
%     im =    imgaussfilt(meanGrayFrame, settings.fgMaskingSettings.gaussianSigmaWidth_pixels);
%     figure,plot(im)
%     mask=im>graythresh(im);
%     
%     SE = strel('square',10);
%     dilatedMask = imdilate( mask,SE);
% 
%         
%     figure,plot(dilatedMask)
%     im
% 
% toc

   molsTooClose = 0;
    % Save the beginning and ending column coordinates for each molecule.
   
    numDetectedChannels = length(averagedKymos);
    channelsRowEdgeIdxs = cell(numDetectedChannels, 1);
    channelsColCenterIdxs = cell(numDetectedChannels, 1);
    channelNumIdxs = cell(numDetectedChannels, 1);

%     import DBM4.find_molecules_in_channel;
    fprintf('Detecting molecules in channels...\n');
    
    % for find_molecules_in_channel, should provide the estimated center
    % position of the molecule?
    
%     detectedChannelNum = 3;
%     meanRotatedMovieFrame=nanmean(wideKymos{detectedChannelNum},3);
    
    %need some clever segmentation within the channel..
    % can't do correlation based here, since don't know how long the
    % fragments are (and edges bias it as well)
%     % Set the background to zero and smooth for peak finding.
%     filteredImgIntensity = meanRotatedMovieFrame;
% %     filteredImgIntensity = filteredImgIntensity .* imgFgMask;
%     
%     
    import OldDBM.MoleculeDetection.apply_gaussian_blur;


%     se = strel('disk', 100);
    SE2 = strel('square',10);

    masks = cell(1,numDetectedChannels);
    for detectedChannelNum = 1:numDetectedChannels
        averagedKymos{detectedChannelNum}(isnan(averagedKymos{detectedChannelNum}))=0;
        meanGrayFrame = averagedKymos{detectedChannelNum};
     
        im =    imgaussfilt(meanGrayFrame, settings.fgMaskingSettings.gaussianSigmaWidth_pixels);
        
        vals = im(meanGrayFrame~=0);
        mask = im>graythresh(vals);
        masks{detectedChannelNum}= imdilate( mask,SE2);
    end
    
    % this is a nice plot to check if we detected everything, maybe include
    % it into the DBM output!
%     idx=38;
%     figure,ax1=subplot(2,1,1);
%     plot(masks{idx}*size(kymos{idx},1));
%     ax2=subplot(2,1,2);
%     imagesc(kymos{idx})
%     linkaxes([ax1 ax2])
%     
    import OldDBM.MoleculeDetection.find_molecules_in_channel;

    for detectedChannelNum = 1:numDetectedChannels
        averagedKymos{detectedChannelNum}(isnan(averagedKymos{detectedChannelNum}))=0;
    
        % Locate the individual molecules
        mol =  averagedKymos{detectedChannelNum}';
        mol(~masks{detectedChannelNum}) = 0;
        [channelRowEdgeIdxs, ~, ~] = find_molecules_in_channel(mol , settings.signalThreshold,settings.fgMaskingSettings.filterEdgeMolecules);%         plot_closest_fit([], channelIntensityCurve, channelMoleculeLabeling, closestFits);

        % check differences between left and right edges  
        if settings.fgMaskingSettings.filterCloseMolecules
            failsFilter = ones(1,size(channelRowEdgeIdxs,1));
            for i=1:size(channelRowEdgeIdxs,1)-1
                if channelRowEdgeIdxs(i+1,1)-channelRowEdgeIdxs(i,2) >= settings.rowSidePadding
                    failsFilter(i) = 0;
                end
            end
            try
                if failsFilter(size(channelRowEdgeIdxs,1)-1) == 0
                    failsFilter(end) = 0;
                end
            catch
                failsFilter(1) = 0;
            end
            molsTooClose = molsTooClose + sum(failsFilter);
            channelRowEdgeIdxs(find(failsFilter),:) = [];
        end
        channelsRowEdgeIdxs{detectedChannelNum} = channelRowEdgeIdxs;
        channelsNum{detectedChannelNum} = detectedChannelNum+ zeros([size(channelRowEdgeIdxs, 1), 1]);
        %
        channelsColCenterIdxs{detectedChannelNum} = peakpos(detectedChannelNum) + zeros([size(channelRowEdgeIdxs, 1), 1]);
    end
    
    if molsTooClose > 0
        fprintf(strcat(['Removed ' num2str(molsTooClose) ' molecules that were too close to each other. Adjust rowSidePadding to reduce the amount of excluded molecules...\n']));
        % otherwise should label these molecules as close to each other
    end
    
    try
    rowEdgeIdxs = vertcat(channelsRowEdgeIdxs{:});
    colCenterIdxs = vertcat(channelsColCenterIdxs{:});
    channelNumIdxs = vertcat(channelsNum{:});
    catch
        rowEdgeIdxs = [];
        colCenterIdxs = [];
        channelNumIdxs = [];
    end

   % for future: maybe use STOMP:
%     idx1=1;
%     idx2=2;
%     idd=3;
%     query=kymos{idd}(1,:);
%     query = query(query~=0);
% %     query(query==0) = nan;
%     data =  kymos{idd}(2,:);
%     data = data(data~=0);
%     % does not include support for nan's at the moment..
%     tic
%     import DBM4.mp_profile_stomp_dna
%     [mp,mpI] = mp_profile_stomp_dna(query', data',100,2^16);
%     toc
%     figure,plot(mp)
% %    figure,imagesc(kymo)
%    
%     
       
   %     figure,imagesc()
%     
%     fprintf('Detecting molecules...\n');
% %     grayscaleVideoRescaled
%     import DBM4.find_molecule_positions;
%     [rowEdgeIdxs, colCenterIdxs] = find_molecule_positions(nanmean(grayscaleVideoRescaled,3), settings);


    numMoleculesDetected = size(rowEdgeIdxs, 1);

    fprintf('Detected a total of %d molecules.\n\n', numMoleculesDetected);
    if numMoleculesDetected==0
        moleculeStructs = {};
    else
        % extract a kymograph for each molecule

        numRows = size(grayscaleVideoRescaled,1);
        numFrames = size(grayscaleVideoRescaled,3);
        numCols = size(grayscaleVideoRescaled,2);

        rowEdgeIdxs(:,1) = max(rowEdgeIdxs(:,1) - rowSidePadding, 1);
        rowEdgeIdxs(:,2) = min(rowEdgeIdxs(:,2) + rowSidePadding, numCols);

        numMoleculesDetected = size(rowEdgeIdxs, 1);

        moleculeStructs = cell(1,numMoleculesDetected);
        for i=1:numMoleculesDetected
            moleculeStructs{i}.miniRotatedMovie =wideKymos{channelNumIdxs(i)}(rowEdgeIdxs(i,1):rowEdgeIdxs(i,2),:,:);
            moleculeStructs{i}.kymograph = kymos{channelNumIdxs(i)}(:,rowEdgeIdxs(i,1):rowEdgeIdxs(i,2));
            % need to add some filters, i.e. is it too close to something?
            % close to the edge? etc
             moleculeStructs{i}.passesFilters = 1;
             
        end
% %         rawFlatKymos = arrayfun(@(moleculeNum) kymos(:, :, moleculeNum), (1:numMoleculesDetected)', 'UniformOutput', false);
%         rawFlatKymos = cellfun(...
%             @(kymo) kymo( ), ...
%             kymos, ...
%             'UniformOutput', false);
%      
%         %	moleculeStructs
%         %     a cell with struct entries, one for each molecule detected
%         moleculeStructs = cellfun(...
%             @(miniRotatedMovie, kymograph) ...
%                 merge_structs( ...
%                     defaultOldMoleculeStruct, ...
%                     struct(...
%                         'frames', miniRotatedMovie, ...
%                         'kymograph',kymograph ...
%                         ) ...
%                     ), ...
%             miniRotatedMovies, ...
%             rawFlatKymos, ...
%             'UniformOutput', false);
%   
%         
%         colSidePadding = averagingWindowSideExtensionWidth;
%         [rotatedMovieSz(1), rotatedMovieSz(2), rotatedMovieSz(3)] = size(grayscaleVideoRescaled);
% 
%         import OldDBM.MoleculeDetection.get_molecule_movie_coords;
%         [miniRotatedMoviesCoords] = get_molecule_movie_coords(rowEdgeIdxs, colCenterIdxs, rotatedMovieSz, rowSidePadding, colSidePadding);
    end
end