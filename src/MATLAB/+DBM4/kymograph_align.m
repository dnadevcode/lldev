function [alignedKymo, stretchFactorsMat, alignedKymoF, alignedMask, shiftAlignedKymoMask]...
    = kymograph_align(unalignedKymo, kymoMask)
    % Kymograph-align - non-recursively aligns a kymograph
    %
    % Inputs:
    %	unalignedKymo
    %	  the unaligned kymograph
    %   skipPrealignTF
    %     true if pre-alignment step should be skipped (e.g. if it has
    %     already been pre-aligned)
    %   kymoMask
    %     true wherever the foreground element of interest is believed to
    %     be located (helps ignore values in background that aren't
    %     relevant)
    %
    % Outputs:
    %	alignedKymo
    %	  the aligned kymograph is output in the last step
    %   stretchFactorsMat
    %	  array of the stretch factor of each pixel in the kymograph
    %   shiftAlignedKymo
    %     the shift aligned kymograph on which stretch factors were
    %     computed to produce the aligned kymograph
    %   alignedMask
    %     the aligned mask
    %   shiftAlignedKymoMask
    %     the shift aligned mask
    %   shiftingVect
    %     the amount each row was shifted prior to feature-based alignment
    %   alignmentSuccessTF
    %     whether the alignment attempt was succesful, false if features
    %     could not be found
    %
    % Authors:
    %	HN, SQ, AD

%     if nargin < 2
%         skipPrealignTF = false;
%     end
    if nargin < 2
        kymoMask = true(size(unalignedKymo));
    end
    
    tic
    
    % %   forceEdgesTF (optional; defaults to false)
    % %     true if forcing alignment near edges
    % if nargin < 4
    %     forceEdgesTF = false;
    % end
    % edgeFeatureAlignmentBuffer = 10;
    
    % STEP1: shift align
    % shift align might fail for molecules touching edges.
    shiftAlignedKymo = unalignedKymo;
    shiftAlignedKymoMask = kymoMask;
    
    unalignedKymo(~kymoMask) = nan;
    
    
    maxFeatureMovementPx = 50; % maximum feature movement frame to frame
        edgePx = 10;
%                 edgePx = maxFeatureMovementPx;


    n = sum(~isnan(unalignedKymo(1,:)))-4*maxFeatureMovementPx; % feature size


    ftMovement = -maxFeatureMovementPx:maxFeatureMovementPx;
    
    % The (maximum) number of features to look for "k"
    minFgMaskWidth = min(min(sum(kymoMask, 2)), (size(kymoMask, 2)));
    nM = ceil(minFgMaskWidth /n);
    shiftMat = zeros(size(kymoMask,1)-1,nM);
    
    kymo2 =    [nan(size(unalignedKymo,1),maxFeatureMovementPx) unalignedKymo nan(size(unalignedKymo,1),100)];
%     bitmask2 = [zeros(size(kymoMask,1),maxFeatureMovementPx) kymoMask zeros(size(kymoMask,1),100)];
%     
%     corScore = zeros(1,size(kymoMask,1)-1);
    


    %%
    
    % create forward and backward vectors, the average then gives a more
    % accurate location
    shiftF = zeros(1,size(kymoMask,1));
    shiftB = zeros(1,size(kymoMask,1));

       % define forward/backward for more accurate 
    for i = 1:size(kymoMask,1)-1

        
        pixelsF = find(kymoMask(i+1,:));
        pixelsB = find(kymoMask(end-i,:));
        
        kF = pixelsF(edgePx:end-edgePx+1);
        kB = pixelsB(edgePx:end-edgePx+1);
        
        vF = unalignedKymo(i+1,kF);
        vB = unalignedKymo(end-i,kB);
        
        scoresF = arrayfun(@(x) nanmean((vF-kymo2(i,maxFeatureMovementPx+kF+x)).^2),ftMovement);
        scoresB = arrayfun(@(x) nanmean((vB-kymo2(end-i+1,maxFeatureMovementPx+kB+x)).^2),ftMovement);

        [valueF, sF] = min(scoresF);
        [valueB, sB] = min(scoresB);

        shiftF(i+1) =   shiftF(i)+ftMovement(sF);
        shiftB(end-i) =  shiftB(end-i+1)+ftMovement(sB);
    end
    
    %% align
    
    %     Align based on shiftF/shiftB
    addedPxF = max(abs(shiftF));
    kymoMaskF = [zeros(size(kymoMask,1), addedPxF) kymoMask zeros(size(kymoMask,1), addedPxF)];
    alignKymoTemp = [zeros(size(kymoMask,1), addedPxF) unalignedKymo zeros(size(kymoMask,1),addedPxF)];
    alignedKymoF = alignKymoTemp;

    for i=2:size(alignedKymoF,1)
        alignedKymoF(i,:) = circshift(  alignKymoTemp(i,:),[0  shiftF(i)]);
        kymoMaskF(i,:) = circshift(  kymoMaskF(i,:),[0  shiftF(i)]);
    end
    
    addedPxB = max(abs(shiftB));
    kymoMaskB = [zeros(size(kymoMask,1), addedPxB) kymoMask zeros(size(kymoMask,1), addedPxB)];
    alignKymoTemp = [zeros(size(kymoMask,1), addedPxB) unalignedKymo zeros(size(kymoMask,1),addedPxB)];
    alignedKymoB = alignKymoTemp;
    for i=2:size(alignedKymoB,1)
        alignedKymoB(end-i+1,:) = circshift(  alignKymoTemp(end-i+1,:),[0 shiftB(end-i+1)]);
    end
    toc
%     figure,imagesc(alignedKymoF);
%     figure,imagesc(kymoMaskF)
    figure,imagesc(alignedKymoB)
    
% %     %%
% %     posDif = zeros(1,size(kymoMask,1));
% %     for i = 1:size(kymoMask,1)
% %         pF =  shiftF(i);
% %         pB =  shiftB(i)-shiftB(1);
% %         posDif(i) = pF-pB;
% %     end
% %     
% %     trueShift = 0:2:2*size(kymoMask,1)-1;
% %     
% %     vals = [shiftF;shiftB-shiftB(1)];
% %     meanShift = mean([shiftF;shiftB+trueShift(end)]);
% %     %% if trueshift known:
% %    f= figure,plot(trueShift-shiftF)
% %     hold on
% % plot((trueShift-trueShift(end))-(shiftB))
% % plot(trueShift-meanShift)
% % title('Forward/backward Euclidean alignment')
% % legend({'Forward','Backward','Averaged'})
% % 
% % %% otherwise
% %    f= figure,plot(shiftF)
% %     hold on
% % plot(shiftB-shiftB(1))
% %     meanShift = mean([shiftF;shiftB-shiftB(1)]);
% % 
% % plot(meanShift)
% % title('Forward/backward Euclidean alignment')
% % legend({'Forward','Backward','Averaged'})
% %     %%
% % f= figure,plot(shiftF)
% % hold on
% % plot(shiftB)
% % 
% % shiftF-shiftF(end)
    
%%
% ignore the first and last pixels
fgMaskExpansionSideWidth = 10;
nanvals = sum(kymoMaskF==0);
st = find(nanvals==0,1,'first');
stop  = find(nanvals==0,1,'last');

% hyper parameters / set outside
squareSmoothingWindowLen_pixels = 10;
blurSigmaWidth_pixels = 2;


%   n = ceil(6 *blurSigmaWidth_pixels);
%   n = n + 1 -mod(n, 2);
%The laplacian of gaussian is obtained and normalized
filt = fspecial('log', [2 squareSmoothingWindowLen_pixels],blurSigmaWidth_pixels);

filtImg = imgaussfilt(alignedKymoF(:,st:stop),3);

alignedKymoF(alignedKymoF==0) = nan;
logim = imfilter(filtImg, filt,nan);
smoothImg = logim ./ max(abs(logim(:)));

  
stShifted = st + fgMaskExpansionSideWidth;
stopShifted = stop - fgMaskExpansionSideWidth;

%% detecting features
%     W_trim = 5;
% depends on camera
typicalFeatureWidth = 11;

% The maximum number of pixels a feature can move from frame to next
% frame
maxFeatureMovementPx = 3;
maxNumFeaturesSoughtK = ceil((stop-st) / typicalFeatureWidth);


mat = smoothImg;%(:, fgMaskExpansionSideWidth:end-fgMaskExpansionSideWidth+1)

% mat = alignedKymoF(:,st:stop);
% maxNumFeaturesSoughtK = 10;

vec =cell(1,size(mat,1));
Ws =cell(1,size(mat,1));

for i=1:size(mat,1) % we loose last row
    [Ypk,Xpk,Wpk] =findpeaks(mat(i,:),'SortStr','descend','NPeaks',maxNumFeaturesSoughtK,'MinPeakDistance',11);
    vec{i} = Xpk';
    Ws{i} = Ypk';
end
% finding k features
distPar = 5;
maxDistFrames = inf;

% track features
import DBM4.track_sources;
[sources] = track_sources(vec,distPar,maxDistFrames,Ws);

% consider sources present in half or more frames
longFeatures = find(cellfun(@(x) size(x,1),sources)>0.9*size(mat,1)-1);
sourcesLong = sources(longFeatures);

f=figure('Position', [100, 100, 600, 300])
%  tiledlayout(2,1)
%  nexttile
% imagesc(kymo)
%  nexttile
hold on
for s = 1:length(sourcesLong)
    plot( sourcesLong{s}(:, 2),sourcesLong{s}(:, 1),'|','linewidth', 2)
end
% ylim([3.95, 5.05])
set(gca, 'YDir','reverse')

pathsColIdxs = nan(size(mat,1), length(sourcesLong));
for i=1:length(sourcesLong)
    pathsColIdxs(sourcesLong{i}(:,1),i) = sourcesLong{i}(:,2);
end

for j=1:size(pathsColIdxs,2)
    % fill up nan's with nearest nonnan
    m = flipud(pathsColIdxs(:,j));
    t = ~isnan(m);
    ii = cumsum(t);
    ii(ii==0) = 1;
    ii = bsxfun(@plus, [0 ii(end,1:end-1)],ii);

    % for s=1:size(ii,2)
    %     ii(:,s) = bsxfun(@plus, [ii(end,s)],ii(:,s));
    % end
    m1 = m(t);
    pathsColIdxs(:,j) = flipud(m1(ii));
end

% end

img = alignedKymoF(:,st:stop);
% alignedMask

imgSz = size(img);
import DBM4.compute_rescale_factors;
stretchFactorsMat = compute_rescale_factors(pathsColIdxs, imgSz);


import OptMap.KymoAlignment.apply_horizontal_stretching;
alignedKymo = apply_horizontal_stretching(img, stretchFactorsMat);
alignedMask = round(apply_horizontal_stretching(double(kymoMaskF(:,st:stop)), stretchFactorsMat)) > 0;


% 
% imgSz = size(alignedKymoF);
% import OptMap.KymoAlignment.compute_stretch_factors;
% stretchFactorsMat = compute_stretch_factors(pathsColIdxs, imgSz);

            
%%
% 
%     tic
% import OptMap.KymoAlignment.find_k_features;
% pathsColIdxOffsets = find_k_features(smoothImg(:, fgMaskExpansionSideWidth:end-fgMaskExpansionSideWidth+1), maxFeatureMovementPx, typicalFeatureWidth, maxNumFeaturesSoughtK); 
%   toc
%   
% import OptMap.KymoAlignment.apply_laplacian_of_gaussian_filter;
% smoothImg = apply_laplacian_of_gaussian_filter(alignedKymoF(:,st:stop), [2, squareSmoothingWindowLen_pixels], blurSigmaWidth_pixels);
% smoothImg = smoothImg ./ max(abs(smoothImg(:)));

% % should erode, not delate, since edges not accurate
% if not(all(kymoMaskF(:)))
%     farBgMask = ~imdilate(kymoMaskF, true(1, 2*fgMaskExpansionSideWidth + 1));
%     smoothImg(farBgMask) = NaN;
% end


    
    
end