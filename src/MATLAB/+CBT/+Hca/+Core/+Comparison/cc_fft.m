%=========================================================================%
function [ ccForward, ccBackward] = cc_fft(shortVec, longVec)
% cross_correlation_coefficients_fft
% input shortVec, longVec
% output ccForward, ccBackward
% Uses FFT to speed up calculation of cross correlations, and is faster than just
% calculating by definition
% updated 07/12/16 by Albertas Dvirnas

    if length(shortVec) > length(longVec)
        tp = longVec;
        longVec = shortVec;
        shortVec = zscore(tp);
    end
    shortLength = size(shortVec,2);
    longLength = size(longVec,2);
    
    shortVecFlip = fliplr(shortVec);
     
    conVec = conj(fft(longVec));
    % Forward cross correlations
    ccForward = (ifft(fft(shortVec,longLength).*conVec))/(shortLength-1);
    ccForward = circshift(ccForward,[0,-1]); 
    ccForward = fliplr(ccForward);

    % Backward cross correlations
    ccBackward = (ifft(fft(shortVecFlip,longLength).*conVec))/(shortLength-1);
    ccBackward = circshift(ccBackward,[0,-1]); 
    ccBackward = fliplr(ccBackward);
    
    % to get Pearson correlation coefficient, need to divide by std
    
    movMean = conv([longVec,longVec(1:shortLength-1)],ones(1,shortLength));
    movMean = movMean(shortLength:longLength+shortLength-1)./shortLength;
    
    movStd = conv([longVec.^2,longVec(1:shortLength-1).^2],ones(1,shortLength));
    movStd = movStd(shortLength:longLength+shortLength-1);

    stdForward = sqrt((movStd-shortLength.*movMean.^2)./(shortLength-1 ));

    ccForward = ccForward ./ stdForward; 
    ccBackward = ccBackward ./stdForward; % std is the same for both forward and backward case

end

