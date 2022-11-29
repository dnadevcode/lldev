function [alignedKymo, stretchFactorsMat, shiftAlignedKymo, alignedMask, shiftAlignedKymoMask, shiftingVect, alignmentSuccessTF] = kymograph_align(unalignedKymo, skipPrealignTF, kymoMask)
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

    if nargin < 2
        skipPrealignTF = false;
    end
    if nargin < 3
        kymoMask = true(size(unalignedKymo));
    end
    
    % %   forceEdgesTF (optional; defaults to false)
    % %     true if forcing alignment near edges
    % if nargin < 4
    %     forceEdgesTF = false;
    % end
    % edgeFeatureAlignmentBuffer = 10;
    
    % shift align might fail for molecules touching edges.
    shiftAlignedKymo = unalignedKymo;
    shiftAlignedKymoMask = kymoMask;
    
    
    n = 50;
    maxFeatureMovementPx = 5;
    ftMovement = -maxFeatureMovementPx:maxFeatureMovementPx;
    
    % The (maximum) number of features to look for "k"
    minFgMaskWidth = min(min(sum(kymoMask, 2)), (size(kymoMask, 2)));
    nM = ceil(minFgMaskWidth /n);
    shiftMat = zeros(size(kymoMask,1)-1,nM);
    
    for i=1:size(kymoMask,1)-1
        % non-zero pixels of this row
        pixels = find(kymoMask(i,:));
        % split into n parts
        out = reshape([pixels';nan(mod(-numel(pixels'),n),1)],n,[]);
        for j=1:nM
            k = out(:,j);
            % compare to next row
            ftC = unalignedKymo(i,k(~isnan(k)));
            % now compare to neighboring positions on next row
            try
                scores = arrayfun(@(x) sum((ftC-unalignedKymo(1+i,k+x)).^2),ftMovement);
            catch
                scores = nan(1,length(ftMovement)); % treat better last case
            end
            [a,b] = min(scores);
            shiftMat(i,j) = ftMovement(b);
%             cumsum(shiftMat(6,:))
        end
%         R = reshape(pixels,maxNumFeaturesSoughtK,[]);
%         feat1 = 
        
    end
    % cumsums gives approximate estimate of shift for that row
        cumsumMat = cumsum(shiftMat,2);
    figure,plot(cumsumMat(:,end)/length(pixels))
    figure,plot(cumsum(cumsumMat(:,end)/length(pixels)))
%     
%     sets.psfnm = 300;
%     sets.nmPerPixel = 110;
%     
%     optics.logSigma = sets.psfnm / sets.nmPerPixel;
%     n = ceil(6 * optics.logSigma);
%     n = n + 1 - mod(n, 2);
%     filt = fspecial('log',[1 n],  optics.logSigma);
%     logim = imfilter(unalignedKymo,filt);
%     
%     findpeaks(-logim(1,:)
% 
%         thedges = imbinarize(logim, 0);
%         
%         thedges = imclose(thedges, true(3));
% %         se1 = strel('line',3,0)
% %         thedges = imdilate(thedges,se1);
% %         
% %         thedges(1:end,[ 1 end]) = 1; % things around the boundary should also be considered
%         thedges([ 1 end],1:end) = 1;
%         
%         
%         % for each feature, cut pixels deviating from the central line
% 
%         [B, L] = bwboundaries(thedges, 'holes');
% 
%         [~, Gdir] = imgradient(logim);
%         
%         % todo: score for each position based on imgradient
%         
%         stat = @(h) mean(h); % This should perhaps be given from the outside
%         
%         longFeats = cellfun(@(x) size(x,1) >= sets.numPts,B);
%         B = B(longFeats);
%         
%         % now hist of B will have two peaks
% %         closedImg = imclose(B{14},strel('disk',30));
% %         k =14;
%     
% 
% %         [counts, binlocation] = imhist(B{14}(:,2));  %plus whatever option you used for imhist
% % [sortedcount, indices] = sort(count);    %sort your histogram
% % peakvalues = sortedcount(1:3)              %highest 3 count in the histogram
% % peaklocations = binlocation(indices(1:3))  %respective image intensities for these peaks
% 
% 
%         meh = zeros(1, length(B));
% 
% %         % find center
% %         posX = cellfun(@(x) mean(x(:,2)),B);
% %         for k = 1:length(B)% Filter out any regions with artifacts in them
% % 
% % 
% %         end
% %         
% 
%         for k = 1:length(B)% Filter out any regions with artifacts in them
%             [N,edges] = histcounts(B{k}(:,2));
%             bcenters = (edges(2:end)+edges(1:end-1))/2;
%             [Ypk,Xpk] = findpeaks([0 N 0],'SortStr','desc','Npeaks',2);
%             % 
%             posEdges = bcenters(Xpk-1);
% 
%             % allow a few pixs variation
%             pL = min(posEdges)-3;  pR = max(posEdges)+3;
% 
%             tooWide = (B{k}(:,2) < pL)+(B{k}(:,2) > pR);
%             B{k}(logical(tooWide),:) = [];
%             meh(k) = edge_score(B{k}, logim, Gdir, 5, stat); %how many points along the gradient to take?
%          end
%         
%         %
%         acc  = zeros(1, length(B));
%         l = zeros(1, length(B));
%         w = zeros(1, length(B));
%         for k = 1:length(B)% Filter any edges with lower scores than lim
%             [acc(k),l(k),w(k)] = mol_filt(B{k}, meh(k), sets.minScoreLambda, inf, [sets.minLambdaLen sets.maxLambdaLen], [1 sets.maxLambdaWidth]); % width depends on psf
%         end
%         
%         
%         potLambda = find(acc==1);
%         posXlambda = zeros(1,length(potLambda));
%         posYlambda =  zeros(length(potLambda),2);
%         posMax =  zeros(1,length(potLambda));
%         for j=1:length(potLambda)
%             posXlambda(j) = round(mean(B{potLambda(j)}(:,2)));
%             posYlambda(j,:) = [min(B{potLambda(j)}(:,1)) max(B{potLambda(j)}(:,1))];
%             posMax(j) = round(mean(posYlambda(j,:)));            
%         end
%         
%         
%     
%     % laplacian of gaussian
% %     if not(skipPrealignTF)
% %         import OptMap.KymoAlignment.NRAlign.pre_nralign_shift_align;
% %         [shiftAlignedKymo, shiftingVect] = pre_nralign_shift_align(shiftAlignedKymo);
% %         import OptMap.KymoAlignment.NRAlign.shift_rows;
% %         shiftAlignedKymoMask = shift_rows(shiftAlignedKymoMask, shiftingVect);
% %     else
% %         shiftingVect = zeros(size(shiftAlignedKymo, 1));
% %     end
%     
%     
%     % The number of pixels around each feature on each side (not including
%     % the pixel the feature is on) on which there may not be another
%     % feature
%     W_trim = 5;
%     typicalFeatureWidth = (2 * W_trim) + 1;
% 
%     % The maximum number of pixels a feature can move from frame to next
%     % frame
%     maxFeatureMovementPx = 7;
% 
% 
%     % The number of pixels to ignore at the edges of the kymograph
%     %  when looking for features
%     featurelessSideWidth = 0;
%     % The edges of the region in which features are to be found are
%     %  specified, unless already done in the call to the function.
%     leftColIdx = 1 + featurelessSideWidth;
%     rightColIdx = size(unalignedKymo, 2) - featurelessSideWidth;
% 
% 
%     % The (maximum) number of features to look for "k"
%     minFgMaskWidth = min(min(sum(shiftAlignedKymoMask, 2)), (size(shiftAlignedKymoMask, 2) - 2*featurelessSideWidth));
%     maxNumFeaturesSoughtK = ceil(minFgMaskWidth / ((2 * W_trim) + 1));
% 
%     
%     % The shift-aligned kymograph is smoothed out in order to reduce noise
%     squareSmoothingWindowLen_pixels = 10;
%     blurSigmaWidth_pixels = 2;
%     
%     import OptMap.KymoAlignment.apply_gaussian_blur;
%     smoothImg = apply_gaussian_blur(shiftAlignedKymo, squareSmoothingWindowLen_pixels, blurSigmaWidth_pixels);
% 
% 
%     %The laplacian of gaussian is obtained and normalized
%     import OptMap.KymoAlignment.apply_laplacian_of_gaussian_filter;
%     smoothImg = apply_laplacian_of_gaussian_filter(smoothImg, [2, 6], 2);% blur sigma should depend on nm/px
%     smoothImg = smoothImg ./ max(abs(smoothImg(:)));
% 
%     % why dilate foreground mask?
% %     fgMaskExpansionSideWidth = 10;
% %     if not(all(shiftAlignedKymoMask(:)))
% %         farBgMask = ~imdilate(shiftAlignedKymoMask, true(1, 2*fgMaskExpansionSideWidth + 1));
% %         smoothImg(farBgMask) = NaN;
% %     end
%      smoothImg(~shiftAlignedKymoMask) = NaN;
%     
%     alignmentSuccessTF = all(sum(~isnan(smoothImg) & (smoothImg ~= 0), 2));
%     stretchFactorsMat = ones(size(shiftAlignedKymo));
%     alignedKymo = shiftAlignedKymo;
%     alignedMask = shiftAlignedKymoMask;
%     
%     
%     if alignmentSuccessTF
%         %The k shortest paths through the (prealigned) kymograph are found
%         import OptMap.KymoAlignment.find_k_features;
%         pathsColIdxOffsets = find_k_features(smoothImg(:, leftColIdx:rightColIdx), maxFeatureMovementPx, typicalFeatureWidth, maxNumFeaturesSoughtK); 
%         
%         alignmentSuccessTF = not(isempty(pathsColIdxOffsets));
%         if alignmentSuccessTF
%             pathsColIdxOffsets = horzcat(pathsColIdxOffsets{:, 1});
%             pathsColIdxs = leftColIdx + pathsColIdxOffsets - 1;
% 
%             
%             % % Force edge alignment -- doesn't currently seem to
%             % %  behave quite as expected (todo: debug)
%             % if forceEdgesTF
%             %     numFrames = size(pathsColIdxs, 1);
%             %     forcedLeftFeature = NaN(numFrames, 1);
%             %     forcedRightFeature = NaN(numFrames, 1);
%             %     for frameNum = 1:numFrames
%             %         tmp = find(alignedMask(frameNum, :), 1, 'first');
%             %         if isempty(tmp)
%             %             tmp = NaN;
%             %         else
%             %             tmp = max(1, tmp - edgeFeatureAlignmentBuffer);
%             %         end
%             %         forcedLeftFeature(frameNum) = tmp;
%             % 
%             %         tmp = find(alignedMask(frameNum, :), 1, 'last');
%             %         if isempty(tmp)
%             %             tmp = NaN;
%             %         else
%             %             tmp = min(size(smoothImg, 2), tmp + edgeFeatureAlignmentBuffer);;
%             %         end
%             %         forcedRightFeature(frameNum) = tmp;
%             %     end
%             %     import OptMap.KymoAlignment.nearest_nonnan;
%             %     forcedLeftFeature = nearest_nonnan(forcedLeftFeature, 1);
%             %     forcedRightFeature = nearest_nonnan(forcedRightFeature, size(smoothImg, 2));
%             %     pathsColIdxs = [forcedLeftFeature, pathsColIdxs, forcedRightFeature];
%             % end
%             
%             imgSz = size(alignedKymo);
%             import OptMap.KymoAlignment.compute_stretch_factors;
%             stretchFactorsMat = compute_stretch_factors(pathsColIdxs, imgSz);
% 
%             import OptMap.KymoAlignment.apply_horizontal_stretching;
%             alignedKymo = apply_horizontal_stretching(alignedKymo, stretchFactorsMat);
%             alignedMask = round(apply_horizontal_stretching(double(alignedMask), stretchFactorsMat)) > 0;
%         end
%     end
%     % put nan's on the non-mask of aligned kymo since that's not relevant
%     % anymore
%     alignedKymo(~alignedMask) = nan;
%     % % For debugging reasons, the paths can be drawn in the (unaligned)
%     % % kymograph.
%     % 
%     % 
%     % 
%     % szImg = size(unalignedKymo);
%     % pathLabelsMat = zeroes(szImg);
%     % numPaths = size(pathsColIdxs, 2);
%     % pathRowIdxs = 1:szImg(1);
%     % for pathNum = 1:numPaths
%     %     pathColIdxs = pathsColIdxs(:, pathNum);
%     %     pathLabelsMat(sub2ind(pathLinIdxs, pathRowIdxs, pathColIdxs)) = pathNum;
%     % end
%     % 
%     % hFig = figure();
%     % hPanel = uipanel('Parent', hFig);
%     % hAxis = axes('Parent', hPanel);
%     % import OptMap.KymoAlignment.UI.plot_features_overlay;
%     % plot_features_overlay(hAxis, unalignedKymo, pathLabelsMat);
end