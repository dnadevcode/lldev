function [peaksToPlot, peakcc,peakint] = find_molecule_channels(image, sets)
    % find_molecule_channels

    % This function finds molecule channels
    
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
    
    import DBM4.find_channels_based_on_corr;
    corrs = find_channels_based_on_corr(image,1);
    corrs = find_channels_based_on_corr(image,1);

%     corrs2 = find_channels_based_on_corr(image,2);
    
    
    %Co uld have some p-value method here on top of CC's
    corrsFarAway = find_channels_based_on_corr(image,50); % parameter here should be in sets!
%     figure, hist(corrsFarAway)
    ccThresh = max(corrsFarAway);

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
%    plot_image_with_peaks(image,peaksToPlot)

    end