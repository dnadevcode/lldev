function [peaksToPlot, peakcc,peakint] = find_molecule_channels_v4(image, sets)
    % find_molecule_channels

    % when computing the correlation, don't consider the whole column, but
    % just the subset of the column
    % This function finds molecule channels
    
%     
%     image1 = image(:,:,1);
%     image2 =  image(:,:,2);
%     image
    % take mean of the image
    mask = nan(size(image));
    mask(image~=0) = 1 ;
%     mask(mask~=1) = nan;
    columnMeans = nanmean(image.*mask);
    
%    rowMeans = nanmean(image.*mask,2);
       
   % in case non-uniform illumination or sth like that:
    %    intensityDrop = imgaussfilt(rowMeans,10)+ zeros(size(image));
    %    imageWithoutDrop = image - intensityDrop;
    
    import DBM4.find_channels_based_on_neighbor_max;
    corrs = find_channels_based_on_neighbor_max(image,1,sets.numPts);
%     corrs2 = find_channels_based_on_corr(image,2);
    
       
    import DBM4.find_channels_based_on_neighbor_max;
    corrsFarAway = find_channels_based_on_neighbor_max(image,50,sets.numPts);

    
    %Co uld have some p-value method here on top of CC's
%     corrsFarAway = find_channels_based_on_corr(image,10); % parameter here should be in sets!
    ccThresh = max(corrsFarAway);
%   ccThresh = 0.4

    intensitymax = movmax(columnMeans,2,'Endpoints','discard' );
    secondIsMax =  intensitymax ~= columnMeans(1:end-1);

   [ peakcc,peakpos] = findpeaks(corrs,'MinPeakDistance',sets.distbetweenChannels);

   peaksToPlot = peakpos(peakcc>ccThresh);
    % correct the position if the second column has the maximum intensity
    peaksToPlot = peaksToPlot+secondIsMax(peaksToPlot);
    peakcc = peakcc(peakcc>ccThresh);
    
   peakint = intensitymax(peaksToPlot);
% 
%    import DBM4.plot_image_with_peaks;
%    plot_image_with_peaks(image1,peaksToPlot)

    end