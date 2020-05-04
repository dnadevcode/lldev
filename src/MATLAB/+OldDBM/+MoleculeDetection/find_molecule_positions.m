function [rowEdgeIdxs, colCenterIdxs] = find_molecule_positions(rotatedMovie, fgMaskingSettings, signalThreshold)
    % find_molecule_positions

    % This function finds molecule positions
    
    % Authors? Edited by Albertas Dvirnas 03/10/17
    
    % Input rotatedMovie, fgMaskingSettings, signalThreshold
    % Output rowEdgeIdxs, colCenterIdxs
    if nargin < 3
        signalThreshold = 0;
    end
    

    
    import AB.Core.get_foreground_mask_movie;
    [fgMaskMov] = get_foreground_mask_movie(permute(rotatedMovie, [1 2 4 3]), fgMaskingSettings);

    %
    % check for pixels that are signal in each frame
    % how to quantify how many molecules we remove by this
    imgFgMask = sum(fgMaskMov,4)>= min(size(fgMaskMov,4),fgMaskingSettings.minMoleculeSize);

    % check that molecules are long enough. This might still remove some
    % good molecules if they move too much, so could reduce the
    % minMoleculeLength parameter..
    imgFgMask(rotatedMovie(:,:,1)==0) = 0;
    % check here already if some columns have molecules too short. But still the molecules can be too short even though 
    % they have been found to be long enough here
    zeroColumns = sum(imgFgMask) <  fgMaskingSettings.minMoleculeLength; 
    imgFgMask(:, zeroColumns) = 0;

    meanRotatedMovieFrame = mean(mean(rotatedMovie, 4), 3);

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

    % Set the background to zero and smooth for peak finding.
    filteredImgIntensity = meanRotatedMovieFrame;
    filteredImgIntensity = filteredImgIntensity .* imgFgMask;
    
    import OldDBM.MoleculeDetection.apply_gaussian_blur;
    smoothingWindowHsize = [min(fgMaskingSettings.smoothingYSize, size(filteredImgIntensity, 1)), min(3, size(filteredImgIntensity, 2))];
    filteredImgIntensity = apply_gaussian_blur(filteredImgIntensity, smoothingWindowHsize,fgMaskingSettings.gaussianSigmaWidth_pixels);

%     filteredImgIntensity = filteredImgIntensity .* imgFgMask;

    % Find the channel coordinates.
    sumProfileForChannelDetection = sum(filteredImgIntensity,1);
    [~, detectedChannelCenterPosIdxs] = findpeaks(sumProfileForChannelDetection);

    molsTooClose = 0;
    % Save the beginning and ending column coordinates for each molecule.
   
    numDetectedChannels = length(detectedChannelCenterPosIdxs);
    channelsRowEdgeIdxs = cell(numDetectedChannels, 1);
    channelsColCenterIdxs = cell(numDetectedChannels, 1);
    import OldDBM.MoleculeDetection.find_molecules_in_channel;
    fprintf('Detecting molecules in channels...\n');

    for detectedChannelNum = 1:numDetectedChannels
        % Extract the channel intensity profile along the channel
        channelIntensityCurve = filteredImgIntensity(:, detectedChannelCenterPosIdxs(detectedChannelNum));
%         channelIntensityCurve2 = meanRotatedMovieFrame(:, detectedChannelCenterPosIdxs(detectedChannelNum));
%         figure,plot(channelIntensityCurve)
        % Locate the individual molecules
        [channelRowEdgeIdxs, channelMoleculeLabeling, closestFits] = find_molecules_in_channel(channelIntensityCurve, signalThreshold,fgMaskingSettings.filterEdgeMolecules);
%         plot_closest_fit([], channelIntensityCurve, channelMoleculeLabeling, closestFits);

        % check differences between left and right edges
        
       
        if fgMaskingSettings.filterCloseMolecules
            
            failsFilter = ones(1,size(channelRowEdgeIdxs,1));
            for i=1:size(channelRowEdgeIdxs,1)-1
                if channelRowEdgeIdxs(i+1,1)-channelRowEdgeIdxs(i,2) >= fgMaskingSettings.rowSidePadding
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
    end
    
    rowEdgeIdxs = vertcat(channelsRowEdgeIdxs{:});
    colCenterIdxs = vertcat(channelsColCenterIdxs{:});
    
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