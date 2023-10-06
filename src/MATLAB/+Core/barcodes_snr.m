function [estSNR] = barcodes_snr(filtKymo,filtBitmask, threshval, threshstd)
    %    
    %   Args:
    %       filtKymo - filtered kymo
    %       filtBitmask - filtered bitmask
    %       threshval - threshold mean
    %       threshstd - threshold std
    %

    % these are from calculating edges
    %     bgMean = cell2mat(dbmStruct.kymoCells.threshval(acceptedBars));
    %     bgStd = cell2mat(dbmStruct.kymoCells.threshstd(acceptedBars));
    
%     estSNR = zeros(1,length(filtKymo));
     
    bgVals = filtKymo(~filtBitmask);
    bgVals = bgVals(~isnan(bgVals));

    threshstd = iqr(bgVals);

    sigVals = filtKymo(filtBitmask);    
    meanSignal = (median(sigVals)-threshval);
    % estimated SNR
    estSNR = meanSignal/threshstd;
% 
%     if length(bgVals) > 1000
%         stdBg = iqr(bgVals);
%     else
%         stdBg = threshstd;
%     end
% 

%     stdBgAndSig = iqr(sigVals);
%     stdSignal = sqrt(stdBgAndSig.^2-stdBg.^2);
% 
%     % More accurate SNR estimate for CB barcodes - only interested in
%     % variance ratio
%     estSNR = (stdSignal.^2)/(stdBg.^2);



end

