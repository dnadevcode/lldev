function [ background_subtracted_kymoImg ] = subtract_kymo_background( kymoImg, signalMask )

    backgroundNoise = nanmean(kymoImg.*~signalMask);
%     figure, plot(backgroundNoise);

    coeff = polyfit(1:length(backgroundNoise),backgroundNoise,1);

    backgroundNoise = coeff(2) + coeff(1) .* (1:length(backgroundNoise));
%     figure, plot(backgroundNoise);

    background_subtracted_kymoImg = kymoImg;
    for row = 1:size(kymoImg,1)
        background_subtracted_kymoImg(row,:) = kymoImg(row,:) - backgroundNoise;
    end
    
end

