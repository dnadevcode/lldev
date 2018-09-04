function [rowEdgeIdxs, colCenterIdxs] = find_molecule_positions(rotatedMovie, fgMaskingSettings, signalThreshold)
    % find_molecule_positions

    % This function finds molecule positions
    
    % Authors? Edited by Albertas Dvirnas 03/10/17
    
    % Input rotatedMovie, fgMaskingSettings, signalThreshold
    % Output rowEdgeIdxs, colCenterIdxs
    if nargin < 3
        signalThreshold = 0;
    end
    
    % minimum size of a molecule. todo: move this to fgMaskingSettings
    % instead of hardcoding here
    fgMaskingSettings.minMoleculeSize = 20;
    fgMaskingSettings.minMoleculeLength = 20;

    import AB.Core.get_foreground_mask_movie;
    [fgMaskMov] = get_foreground_mask_movie(permute(rotatedMovie, [1 2 4 3]), fgMaskingSettings);
    
    %
    % check for pixels that are signal in each frame
    imgFgMask = sum(fgMaskMov,4)>= min(size(fgMaskMov,4),fgMaskingSettings.minMoleculeSize);
    
    % check that molecules are long enough. This might still remove some
    % good molecules if they move too much, so could reduce the
    % minMoleculeLength parameter..
    zeroColumns = sum(imgFgMask) <  fgMaskingSettings.minMoleculeLength;
    imgFgMask(:,zeroColumns) = 0;
    

    meanRotatedMovieFrame = mean(mean(rotatedMovie, 4), 3);
    
    % Set the background to zero and smooth for peak finding.
    filteredImgIntensity = meanRotatedMovieFrame;
    filteredImgIntensity = filteredImgIntensity .* imgFgMask;
    
    import OldDBM.MoleculeDetection.apply_gaussian_blur;
    smoothingWindowHsize = [min(50, size(filteredImgIntensity, 1)), min(3, size(filteredImgIntensity, 2))];
    filteredImgIntensity = apply_gaussian_blur(filteredImgIntensity, smoothingWindowHsize);

    % Find the channel coordinates.
    sumProfileForChannelDetection = sum(filteredImgIntensity,1);
    [~, detectedChannelCenterPosIdxs] = findpeaks(sumProfileForChannelDetection);

    % Save the beginning and ending column coordinates for each molecule.

    numDetectedChannels = length(detectedChannelCenterPosIdxs);
    channelsRowEdgeIdxs = cell(numDetectedChannels, 1);
    channelsColCenterIdxs = cell(numDetectedChannels, 1);
    import OldDBM.MoleculeDetection.find_molecules_in_channel;
    for detectedChannelNum = 1:numDetectedChannels
        % Extract the channel intensity profile along the channel
        channelIntensityCurve = filteredImgIntensity(:, detectedChannelCenterPosIdxs(detectedChannelNum));

        % Locate the individual molecules
        [channelRowEdgeIdxs, channelMoleculeLabeling, closestFits] = find_molecules_in_channel(channelIntensityCurve, signalThreshold);
        % plot_closest_fit([], channelIntensityCurve, channelMoleculeLabeling, closestFits);

        channelsRowEdgeIdxs{detectedChannelNum} = channelRowEdgeIdxs;
        channelsColCenterIdxs{detectedChannelNum} = detectedChannelCenterPosIdxs(detectedChannelNum) + zeros([size(channelRowEdgeIdxs, 1), 1]);
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