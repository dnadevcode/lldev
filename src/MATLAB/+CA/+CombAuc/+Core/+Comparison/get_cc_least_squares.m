function [ xcorrs,coverage,fullCoverage ] = get_cc_least_squares( shortVec, longVec, shortVecBit, longVecBit )
    % get_cc_least_squares
    
    % input shortVec, longVec, shortVecBit, longVecBit 
    
    % output xcorrs
    
    
    shortVec = shortVec(:)';
    longVec = longVec(:)';
    if nargin < 3
        shortVecBit = true(size(shortVec));
    end
    if nargin < 4
        longVecBit = true(size(longVec));
    end
    shortVecBit = shortVecBit(:)';
    longVecBit = longVecBit(:)';
   
    shortVecCut = shortVec(logical(shortVecBit));
    shortLength = length(shortVecCut);
    longLength = length(longVec);
    
    movMean = conv([double(longVecBit),double(longVecBit(1:shortLength-1))],ones(1,shortLength));
    coverage = movMean(shortLength:longLength+shortLength-1);
    if length(shortVec) > length(longVec)
        tp = longVec;
        longVec = shortVec;
        shortVecCut = tp;
        longLength = length(longVec);
        shortLength = length(shortVecCut);
      %  shortVec = zscore(tp);
    end
    

    shortVecCutR = fliplr(shortVecCut);

    ccForward = zeros(1,longLength);
    ccBackward = zeros(1,longLength);

    shortVecCut = shortVecCut/mean(shortVecCut);
    shortVecCutR = shortVecCutR/mean(shortVecCutR);
    for i=1:longLength
        longV = circshift(longVec, [0,-i+1]);
        longV = longV(1:shortLength)/mean(longV(1:shortLength));
        ccForward(i) = sum((shortVecCut-longV).^2);    
        ccBackward(i) = sum((shortVecCutR-longV).^2);        
    end
    
    
 
%     

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
%     ccForward = ccForward ./ stdForward; 
%     ccBackward = ccBackward ./stdForward; % std is the same for both forward and backward case
% 
% 
%     ccBackward = circshift(ccBackward,[0,length(shortVec)+1-find(shortVecBit,1,'first')]);
%     ccForward = circshift(ccForward,[0,1-find(shortVecBit,1,'first')]);
    xcorrs = [ccForward;ccBackward];
    
    fullCoverage = coverage==length(shortVecCut);

   % coverageLens = coverageLens(:, colIndices);
end

