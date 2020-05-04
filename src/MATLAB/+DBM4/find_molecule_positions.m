function [rowEdgeIdxs, colCenterIdxs] = find_molecule_positions(rotatedMovie, sets)
    % find_molecule_positions

    % This function finds molecule positions
    
    % Authors? Edited by Albertas Dvirnas 03/10/17
    
    % Input rotatedMovie, fgMaskingSettings, signalThreshold
    % Output rowEdgeIdxs, colCenterIdxs
%     if nargin < 3
%         signalThreshold = 0;
%     end
    
    tic
    % investigate every row, and graythresh in each col. alternatively, use
    % tanh function for fitting in each col
    thresholds = zeros(1,size(rotatedMovie,2));
    fgMaskMov = zeros(size(rotatedMovie));
    fgMaskMov2 = zeros(size(rotatedMovie));

%         fgMaskMov2 = zeros(size(fgMaskMov));

%           % make sure that amplification does not add extra strange molecules
%     import AB.Processing.amplify_movie;
%     szInit = size(rotatedMovie);
%         maxAmpDist = sets.fgMaskingSettings.maxAmpDist;
% 
%     [rotatedMovieAmp] = amplify_movie(rotatedMovie, maxAmpDist);
%     
    
    % basic approach: no filtering, just threshold the columns
%     
% %      findchangepts - slow method
%     % foreground for each column
%     resErrors = zeros(1,size(fgMaskMov,2));
%     changepoints = cell(1,size(fgMaskMov,2));
%     for i=1:size(fgMaskMov,2)
%         i
%         A = rotatedMovie(:,i);
%         vals = A(A~=0);
%         [changepoints{i}, resErrors(i)] = findchangepts(vals,'MaxNumChanges',2); % how many molecules to detect
% 
% %         fgMaskMov(:,i) = A>graythresh(vals);        
% %         fgMaskMov(:,i) = bwareafilt(logical(rotatedMovie(:,i)),[20 size(fgMaskMov,2)]);
%         % count number of continuous values passing the threshold
%     end
%      A = rotatedMovie(:,293);
%      vals = A(A~=0);
%      
%      TF = ischange(vals)
%      
%      figure
% findchangepts(vals,'MaxNumChanges',2) % how many molecules to detect
% figure
% findchangepts(imgaussfilt(vals,3),'MaxNumChanges',2) % how many molecules to detect

% then will need to check for significance of these change points

%     import OptMap.KymoAlignment.apply_laplacian_of_gaussian_filter;
%     k = apply_laplacian_of_gaussian_filter(rotatedMovie, [1, 6], 2);
%     figure,imagesc(k)
%     
%     k(k>0) = k(k>0) ./ max(k(:));
%     k(k<0) = k(k<0) ./ max(-k(:));
% 
%     kUp = k;
%     kUp(kUp>0) = 1 - kUp(kUp>0);
%     kUp(kUp<=0) = barrierVal; 
% 
%     kDown = -k;
%     kDown(kDown>0) = 1 - kDown(kDown>0);
%     kDown(kDown<=0) = barrierVal;
% 
%     distArr = [inf, inf];
%     alignXValsArr = zeros(rows,2);

idx = 422
 figure,plot(rotatedMovie(:,idx))
hold on
plot(rotatedMovie(:,idx+1))
plot(rotatedMovie(:,idx+2))
plot(rotatedMovie(:,idx+3))
plot(rotatedMovie(:,idx+4))
legend({'idx+1','idx+2','idx+3','idx+4','idx+5'})

    
    tic
    % foreground for each column
    for i=1:size(fgMaskMov,2)
        A = rotatedMovie(:,i);
        vals = A(A~=0);
        thresholds(i) = graythresh(vals);
        fgMaskMov(:,i) = A>graythresh(vals);        
%         fgMaskMov(:,i) = bwareafilt(logical(rotatedMovie(:,i)),[20 size(fgMaskMov,2)]);
        % count number of continuous values passing the threshold
    end
    toc
    
    % idea: a lot of channels,split the image into nanochannel tracks
    % thresholds is an estimator of nanochannel meander tracks
    
       [a,detectedChannelCenterPosIdxs,c,d] = findpeaks(imgaussfilt(thresholds,2.3),'SortStr','descend');

       % estimate of channel 
       offset = 2;
       width = 8.5;
       edge=3;
       
       rotatedMovie(rotatedMovie==0)=nan;
%        [X,Y] = meshgrid(1:size(rotatedMovie,2),1:size(rotatedMovie,1));
%        data = interp2(X,Y,rotatedMovie,repmat(103,1,size(rotatedMovie,1)),1:size(rotatedMovie,2));
% %        figure,plot(data)

       % could also add angle to this..
       import DBM4.minimize_channel_value
              import DBM4.minimize_channel_value2

       [value] = minimize_channel_value(rotatedMovie, offset, width);
       
       fun = @(x) minimize_channel_value(rotatedMovie, x(1), x(2));
      fun2 = @(x) minimize_channel_value2(rotatedMovie, x(1), x(2));
% 
%         x0 = [4,9];
% %         x1 = [4,7];
% % 
% tic
%         fun2(x0)
%         toc
%         fun(x1)   
    vals = [];
    idd=3:0.05:11;
    for ii=idd
        vals = [vals fun([2,ii])];
    end
    
        figure,plot(idd,vals)
        
        
%         fun(x1)   
    vals = [];
    idd=0:0.4:15;
    for ii=idd
        vals = [vals fun([ii,5.8])];
    end
    
                figure,plot(idd,vals)
                
              [intensities,locs]=  findpeaks(vals)

        
        lb = [0,7];
        ub = [6,10];
        
        x0 = (lb + ub)/2;
        
        A = [];
        b = [];
        Aeq = [];
        beq = [];
        % A = [1,2];
        % b = 1;
        y = fmincon(fun,x0,A,b,Aeq,beq,lb,ub);
%        y = fmincon(fun,x0,A,b)
% 
%        
%        minfun = @(x,y) 
%        
       subImage = cell(1,length(1:width:size(fgMaskMov,2)-width+1));
       indexes = round(1:width:size(fgMaskMov,2)-width+1);
       
       for idx=1:length(indexes)
           i = indexes(idx);
           A = rotatedMovie(:,i:i+round(width)-1);
           subImage{idx} = A(:,edge:end-edge+1);
       end
       
       % based on the initial channel width, run a minimization procedure
       % here that detects the best offset and channel width, i.e. so that
       % the centers of all the detected molecules fall into this
       
       %simple minimization: consider the amount of signal within channels.
       %i.e. just compute the mean
       
       funtominimize = @(x) sum(cellfun(@(x) mean(x(:)),subImage))
       
%        sort(diff(sort(detectedChannelCenterPosIdxs(1:20))))
    
%         tic
%     % foreground for each column
%     for i=1:size(fgMaskMov,2)
%         A = rotatedMovie(:,i);
%         vals = A(A~=0);
%         thresholds(i) = graythresh(vals);
%         fgMaskMov(:,i) = A>graythresh(vals);        
% %         fgMaskMov(:,i) = bwareafilt(logical(rotatedMovie(:,i)),[20 size(fgMaskMov,2)]);
%         % count number of continuous values passing the threshold
%     end
%     
%     tic
%     numC = 3;
%     thresholds2 = nan(1,size(fgMaskMov,2));
%     for i=1:size(fgMaskMov,2)-numC+1
%         A = rotatedMovie(:,i:i+numC-1);
%         A(A==0) = nan;
%         meanA = nanmean(A');
%         filteredA = imgaussfilt(meanA,3);
%         filteredA= meanA;
% %         figure,plot()
%         vals = filteredA(filteredA~=0);
%         thresholds2(i) = graythresh(vals);
% 
%         thresholds(i) = graythresh(vals(:));
%         fgMaskMov2(:,i) = double(vals>graythresh(vals));
% %         fgMaskMov2(:,i) = bwareafilt(logical(rotatedMovie(:,i)),[20 size(fgMaskMov,2)]);
%         % count number of continuous values passing the threshold
%     end
%     toc
%     figure,plot(thresholds)
%     thresholdspassing = thresholds> graythresh(thresholds);
%     fgMaskMov(:,~thresholdspassing) = 0;
%     figure,imagesc(fgMaskMov)


%     y = medfilt1(vals,4)
    
%     toc
    
    
    % find the peaks in thresholds. this will include also noise..
   [a,detectedChannelCenterPosIdxs,c,d]= findpeaks(imgaussfilt(thresholds,2.3),'SortStr','descend');
   % 'NPeaks',sets.maxNumChannels
   % 'maxPeakHeight'...

    
%         tic
%     % foreground for each column
%     for i=1:size(fgMaskMov,2)
%         A = rotatedMovie(i,:);
%         vals = A(A~=0);
%         thresholds2(i) = graythresh(vals);
%         fgMaskMov2(i,:) = A>graythresh(vals);        
% %         fgMaskMov(:,i) = bwareafilt(logical(rotatedMovie(:,i)),[20 size(fgMaskMov,2)]);
%         % count number of continuous values passing the threshold
%     end
%     
%     toc
%     
% %     fgMaskMov2 = zeros(size(fgMaskMov));
%     A = rotatedMovie(:,1020);
%     vals1 = A(A~=0);
%     thr1 =  graythresh(vals1);
% 
%     B = rotatedMovie(:,1022);
%     vals2 = B(B~=0);
%     thr2 =  graythresh(vals2);
%     
%      % use kmeans to separate indexes in background and forward
%     [idx1,~] = kmeans(vals1,2);
%     % make sure indexes are unique
%     [~,~,idx1] = unique(idx1,'stable');
%     idx1 = idx1-1;
%     (nanmean(vals1(idx1==1))+nanmean(vals1(idx1==0)))/2

    %
%     % find first signal index
%     leftEdgeIdxs(i) = find(idx1,1,'first');
%     % find last signal index
%     rightEdgeIdxs(i) = find(idx1,1,'last');
        
   
%    fgMaskMov2(nonzeroChannels) = 1;
   % could also: run this for rows, for multicolumns and then average,
   % etc..
   
    % Set the background to zero and smooth for peak finding.
%     filteredImgIntensity = rotatedMovie;
%     filteredImgIntensity = filteredImgIntensity .* fgMaskMov2;
%     
%     import OldDBM.MoleculeDetection.apply_gaussian_blur;
%     smoothingWindowHsize = [min(sets.fgMaskingSettings.smoothingYSize, size(filteredImgIntensity, 1)), min(3, size(filteredImgIntensity, 2))];
%     filteredImgIntensity = apply_gaussian_blur(filteredImgIntensity, smoothingWindowHsize,sets.fgMaskingSettings.gaussianSigmaWidth_pixels);

    channelI = cell(1,length(detectedChannelCenterPosIdxs));
    foregroundI =  cell(1,length(detectedChannelCenterPosIdxs));
    fgMaskFull = zeros(size(rotatedMovie));
    
    %todo: apply gaussian filter before for more stable results in case of
    %noise

    for i=1:length(detectedChannelCenterPosIdxs)
        channelI{i} = rotatedMovie(:,detectedChannelCenterPosIdxs(i));      
         channelI{i}( channelI{i}==0 ) = nan;
%          bwareafilt(logical(rotatedMovie(:,i)),[20 size(fgMaskMov,2)])
         foregroundI{i} =   bwareafilt(logical(fgMaskMov(:,detectedChannelCenterPosIdxs(i))),[sets.fgMaskingSettings.minMoleculeLength length(channelI{i})]);
         
         % dilate the mask a little bit, so features that are very close to
         % each other would be merged
         SE = strel('square',10);
        foregroundI{i} = imdilate( foregroundI{i},SE);

         fgMaskFull( foregroundI{i},detectedChannelCenterPosIdxs(i)) =  channelI{i}(foregroundI{i});
         
%          if sum(foregroundI{i}==1) == 0
%              detectedChannelCenterPosIdxs(i)
%          end
%         if sum(foregroundI{i})==0
%              channelI{i} =[];
%              foregroundI{i} = [];
%         end
    end
    
%     figure,imagesc(rotatedMovie)
%     figure,imagesc(fgMaskFull)

%     filteredImgIntensity = filteredImgIntensity .* fgMaskMov2;

    % Find the channel coordinates.
%     sumProfileForChannelDetection = sum(filteredImgIntensity,1);
%     [~, detectedChannelCenterPosIdxs] = findpeaks(sumProfileForChannelDetection);

    molsTooClose = 0;
    % Save the beginning and ending column coordinates for each molecule.
   
    numDetectedChannels = length(detectedChannelCenterPosIdxs);
    channelsRowEdgeIdxs = cell(numDetectedChannels, 1);
    channelsColCenterIdxs = cell(numDetectedChannels, 1);
    import DBM4.find_molecules_in_channel;
    fprintf('Detecting molecules in channels...\n');

    
    for detectedChannelNum = 1:numDetectedChannels
        % Extract the channel intensity profile along the channel
%         channelIntensityCurve = filteredImgIntensity(:, detectedChannelCenterPosIdxs(detectedChannelNum));
%         channelIntensityCurve2 = meanRotatedMovieFrame(:, detectedChannelCenterPosIdxs(detectedChannelNum));
%         figure,plot(channelIntensityCurve)
        % Locate the individual molecules
        [channelRowEdgeIdxs, channelMoleculeLabeling, closestFits] = DBM4.find_molecules_in_channel(  channelI{detectedChannelNum},foregroundI{detectedChannelNum}, sets.signalThreshold);%         plot_closest_fit([], channelIntensityCurve, channelMoleculeLabeling, closestFits);

        % check differences between left and right edges
        
       
        if sets.fgMaskingSettings.filterEdgeMolecules
            
            failsFilter = ones(1,size(channelRowEdgeIdxs,1));
            for i=1:size(channelRowEdgeIdxs,1)-1
                if channelRowEdgeIdxs(i+1,1)-channelRowEdgeIdxs(i,2) >= sets.rowSidePadding
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
        channelsColCenterIdxs{detectedChannelNum} = detectedChannelCenterPosIdxs(detectedChannelNum) + zeros([size(channelRowEdgeIdxs, 1), 1]);
    end
    
    if molsTooClose > 0
        fprintf(strcat(['Removed ' num2str(molsTooClose) ' molecules that were too close to each other. Adjust rowSidePadding to reduce the amount of excluded molecules...\n']));
        % otherwise should label these molecules as close to each other
    end
    
    rowEdgeIdxs = vertcat(channelsRowEdgeIdxs{:});
    colCenterIdxs = vertcat(channelsColCenterIdxs{:});
    
    
%    
%    % represent channel values 
%    b
%     fgMaskMov2(:,b)= 1;
%    
% %     se = strel('disk',2)
% %     background = imopen(rotatedMovie,se);
% %     I2 = rotatedMovie - background;
% 
%     % compute running mean of the thresh score..
%     i = 1
%     A = rotatedMovie(:,i);
%     vals = A(A~=0);
%     thresholds(i) = graythresh(vals);
%     fgMaskMov(:,i) = A>graythresh(vals);
%     close all
%     figure,plot(A)
% % figure,plot(fgMaskMov(:,i))
% 
%     aboveNoiseT = mean(vals(vals<graythresh(vals)))+3*std(vals(vals<graythresh(vals)));
% 
%     
%         % so 
%         aboveNoise =  A > aboveNoiseT;
%         figure,plot(A>aboveNoiseT)
% %      
%     figure,plot( fgMaskMov(:,i))
% 
%     
%     for i=1:size(fgMaskMov,2)
%         A = rotatedMovie(i,:);
%         vals = A(A~=0);
%         thresholds(i) = graythresh(vals);
%         fgMaskMov2(i,:) = A>graythresh(vals);
% %         fgMaskMov2(:,i) = bwareafilt(logical(rotatedMovie(:,i)),[20 size(fgMaskMov,2)]);
%         % count number of continuous values passing the threshold
%     end
%     
%     % now, we could have a stride of (say 3 elements), to select correct
%     % molecule
%     toc
%     figure,imagesc(fgMaskMov==6)
%         figure,imagesc(fgMaskMov2)
% 
%             fgMaskMov = zeros(size(rotatedMovie));
% 
%     numC = 6;
%     for i=1:size(fgMaskMov,2)-numC+1
%         A = rotatedMovie(:,i:i+numC-1);
%         vals = A(A~=0);
%         thresholds(i) = graythresh(vals(:));
%         fgMaskMov(:,i:i+numC-1) =fgMaskMov(:,i:i+numC-1)+ double( A>graythresh(vals));
% %         fgMaskMov2(:,i) = bwareafilt(logical(rotatedMovie(:,i)),[20 size(fgMaskMov,2)]);
%         % count number of continuous values passing the threshold
%     end
%     figure,plot(thresholds)
%     thresholdspassing = thresholds> graythresh(thresholds);
%     fgMaskMov(:,~thresholdspassing) = 0;
%     figure,imagesc(fgMaskMov)

%     
%     import AB.Core.get_foreground_mask_movie;
%     [fgMaskMov] = get_foreground_mask_movie(permute(rotatedMovie, [1 2 4 3]), fgMaskingSettings);
%     
%     %
%     % check for pixels that are signal in each frame
%     % how to quantify how many molecules we remove by this
%     imgFgMask = sum(fgMaskMov,4)>= min(size(fgMaskMov,4),fgMaskingSettings.minMoleculeSize);
% 
%     % check that molecules are long enough. This might still remove some
%     % good molecules if they move too much, so could reduce the
%     % minMoleculeLength parameter..
%     imgFgMask(rotatedMovie(:,:,1)==0) = 0;
%     % check here already if some columns have molecules too short. But still the molecules can be too short even though 
%     % they have been found to be long enough here
%     zeroColumns = sum(imgFgMask) <  fgMaskingSettings.minMoleculeLength; 
%     imgFgMask(:, zeroColumns) = 0;
% 
%     meanRotatedMovieFrame = mean(mean(rotatedMovie, 4), 3);

    %     I = meanRotatedMovieFrame;
    %     % normalize histogram 
    % %     se = strel('disk',5)
    % 	se = strel('rectangle',[15,3]);
    % 
    %     background = imopen(meanRotatedMovieFrame,se);
    % %     figure,imagesc(background)
    %     meanRotatedMovieFrame = meanRotatedMovieFrame - background;
    %     
    %     figure,imagesc(I2)
    % figure,imagesc(I)
    % figure,imagesc(meanRotatedMovieFrame);

    % function [] = plot_closest_fit(hAxis, channelIntensityCurve, channelMoleculeLabeling, closestFits)
    %     if isempty(hAxis)
    %         hFig = figure();
    %         hPanel = uipanel('Parent', hFig);
    %             hAxis = axes('Parent', hPanel);
    %     end
    %     closestFit = NaN(size(channelIntensityCurve));
    %     for labelNum = 1:max(channelMoleculeLabeling)
    %         labelMask = (channelMoleculeLabeling == labelNum);
    %         closestFit(labelkMask) = closestFits(labelMask);
    %     end
    %     plot(hAxis, channelIntensityCurve);
    %     hold(hAxis, 'on');
    %     plot(hAxis, closestFit, '--');
    % end
end