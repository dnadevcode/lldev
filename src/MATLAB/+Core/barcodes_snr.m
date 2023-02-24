function [estSNR] = barcodes_snr(filtKymo,filtBitmask, threshval, threshstd)
    %    

    % these are from calculating edges
    %     bgMean = cell2mat(dbmStruct.kymoCells.threshval(acceptedBars));
    %     bgStd = cell2mat(dbmStruct.kymoCells.threshstd(acceptedBars));
    
%     estSNR = zeros(1,length(filtKymo));
     

    if nargin < 3
        bgVals = filtKymo(~filtBitmask);
        threshval = nanmedian(bgVals); %
        threshstd = iqr( bgVals );
    end
    sigVals = filtKymo(filtBitmask);    
    meanSignal = (median(sigVals)-threshval);
    % estimated SNR
    estSNR = meanSignal/threshstd;



end

