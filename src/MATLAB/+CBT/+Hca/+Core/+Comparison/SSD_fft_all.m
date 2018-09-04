%=========================================================================%
function [ssdV,ssdB, indices] = SSD_fft_all(rawBarcodeFiltered1,rawBarcodeFiltered2, rawBit1, rawBit2, alowedShift)
% sum_square_difference_coefficients_fft
% input shortVec, longVec
% output ccForward, ccBackward
% Uses FFT to speed up calculation of cross correlations, and is faster than just
% calculating by definition
% update) 11/07/17 by Albertas Dvirnas
    lenDif = length(rawBarcodeFiltered1)-length(rawBarcodeFiltered2);
 
    if lenDif > 0
        rawBarcodeFiltered2 =[rawBarcodeFiltered2 zeros(1,lenDif)];
        rawBit2 = [ rawBit2 zeros(1,lenDif)];
    else
        rawBarcodeFiltered1 =[rawBarcodeFiltered1 zeros(1,-lenDif)];
        rawBit1 = [ rawBit1 zeros(1,-lenDif)];
    end
	ssdV = [];
    ssdB = [];
    indices = -alowedShift:alowedShift ;

    for cS = indices
        indBit = logical(rawBit1.*circshift(rawBit2,[0,cS]));
        r1 = rawBarcodeFiltered1(indBit);
        
        shifted2 = circshift(rawBarcodeFiltered2,[0,cS]);
        
%         length(shifted2)
%         length(indBit)

        r2 = shifted2(indBit);
        ssdV = [ssdV sum((r1-r2).^2/(length(r1)-1))];
    end
    
     rawBarcodeFiltered2 = fliplr(rawBarcodeFiltered2);
     rawBit2 = fliplr(rawBit2);
     
     for cS = indices
        indBit = logical(rawBit1.*circshift(rawBit2,[0,cS]));
        r1 = rawBarcodeFiltered1(indBit);

        shifted2 = circshift(rawBarcodeFiltered2,[0,cS]);
        r2 = shifted2(indBit);
        ssdB = [ssdB sum((r1-r2).^2/(length(r1)-1))];
    end
    

        
        
%     if length(shortVec) > length(longVec)
%         tp = longVec;
%         longVec = shortVec;
%         shortVec = zscore(tp);
%     end
%     shortLength = size(shortVec,2);
%     longLength = size(longVec,2);
%     
%     shortVecFlip = fliplr(shortVec);
%      
%     conVec = conj(fft(longVec));
%     % Forward cross correlations
%     ccForward = (ifft(fft(shortVec,longLength).*conVec))/(shortLength-1);
%     ccForward = circshift(ccForward,[0,-1]); 
%     ccForward = fliplr(ccForward);
% 
%     % Backward cross correlations
%     ccBackward = (ifft(fft(shortVecFlip,longLength).*conVec))/(shortLength-1);
%     ccBackward = circshift(ccBackward,[0,-1]); 
%     ccBackward = fliplr(ccBackward);
%     
%     % to get Pearson correlation coefficient, need to divide by std
%     
%     movMean = conv([longVec,longVec(1:shortLength-1)],ones(1,shortLength));
%     movMean = movMean(shortLength:longLength+shortLength-1)./shortLength;
%     
%     movStd = conv([longVec.^2,longVec(1:shortLength-1).^2],ones(1,shortLength));
%     movStd = movStd(shortLength:longLength+shortLength-1);
% 
%     stdForward = sqrt((movStd-shortLength.*movMean.^2)./(shortLength-1 ));
% 
% 
%     ccForward = ccForward ./ stdForward; 
%     ccBackward = ccBackward ./stdForward; % std is the same for both forward and backward case

end

