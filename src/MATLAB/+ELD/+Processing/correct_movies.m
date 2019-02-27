function [ correctedMovie,matrixMask ] = correct_movies( loadedMovie,sets )
    % correct_movies
    % Correct loaded Movies to remove hot (pixels that have
    % significantly high value as compared to the median filter of the
    % pixel values)
    
    % :param loadedMovie: movie to correct pixels in.
    % :param sets: settings.

    % :returns: correctedMovie,matrixMask
    
    % written by Albertas Dvirnas
    
   
    % first we need to remove dead pixels.
    differenceImage = zeros(size(loadedMovie));
    for i=1:size(loadedMovie,3)
       differenceImage(:,:,i) = abs(loadedMovie(:,:,i)-medfilt2(loadedMovie(:,:,i),sets.medianfilter,'symmetric'));
    end

    meanDifference = mean(differenceImage(:));
    stdDifference = std(differenceImage(:));
    threshVal = meanDifference+sets.threshLevel*stdDifference; % number of std should be based on the movie size!
    
    % mask for hot pixels. Should take max? or mean?
    matrixMask = uint16(max(differenceImage,[],3) < threshVal);

    correctedMovie = loadedMovie;
    for i=1:size(correctedMovie,3)  %can we keep it int16
       filtImg = medfilt2(loadedMovie(:,:,i),sets.medianfilter,'symmetric');
       correctedMovie(:,:,i) = correctedMovie(:,:,i).*matrixMask+filtImg.*uint16(~matrixMask);

    end

    % scale movie intensities to be from 0 to 2^16-1
    maxMov = max(correctedMovie(:));
    minMov = min(correctedMovie(:));
    for i=1:size(correctedMovie,3) 
        tempCor =  correctedMovie(:,:,i);
        correctedMovie(:,:,i) = round((tempCor-minMov)*((2^16)/(maxMov-minMov)));
    end
    
end

