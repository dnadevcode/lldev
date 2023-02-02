function [rezMaxM,bestBarStretch,bestLength] = quick_cc(barcodeGen,lambdaScaled, lambdaMask, stretchFactors,meanD)

rezMaxM = cell(1,length(barcodeGen));
bestBarStretch = zeros(1,length(barcodeGen));
bestLength = zeros(1,length(barcodeGen));
% for all the barcodes run
% parfor
% import OptMap.KymoAlignment.SPAlign.masked_cc_corr;

minLen = 0.8*sum(lambdaMask);
import DBM4.masked_cc_with_reverse;

for idx=1:length(barcodeGen)
%         idx
        barTested = barcodeGen{idx}.rawBarcode;
        barBitmask = barcodeGen{idx}.rawBitmask;
        lenBarTested = length(barTested);

        % xcorrMax stores the  maximum coefficients
        xcorrMax = zeros(1,length(stretchFactors));
        
        % rezMaz stores the results for one barcode
        rez = cell(1,length(stretchFactors));
%         rez = [];
        % run the loop for the stretch factors
        for j=1:length(stretchFactors)
            % here interpolate both barcode and bitmask 
            barC = interp1(barTested, linspace(1,lenBarTested,lenBarTested*stretchFactors(j)));
            barC = barC - meanD(idx);
            barC = barC/max(barC);
            barB = barBitmask(round(linspace(1,lenBarTested,lenBarTested*stretchFactors(j))));
            [ xcorrs, numElts ] = masked_cc_with_reverse(barC , [lambdaScaled  zeros(1,lenBarTested)],...
                barB,[lambdaMask zeros(1,lenBarTested)],minLen ); %todo: include division to k to reduce mem
            
%             xcorrs(:,length(lambdaMask)+1:end) = nan;% mask these parts
            numElts(numElts<(minLen)) = nan;

            xcorrs = xcorrs./sqrt(numElts);
            [f,s] = nanmin(xcorrs);
            % sort the max scores, ix stores the original indices
            [ b, ix ] = sort( f(:), 'ascend','MissingPlacement','last' );

            % choose the best score
            indx = b(1) ;
            % save the best max score and orientation
            rez{j}.maxcoef = indx;
            rez{j}.or = s(ix(1));
            rez{j}.overlap = numElts(s(ix(1)),ix(1));
            % finally, save the position. This can have two cases,
            % depending on the value of s
            rez{j}.pos = ix(1);
            xcorrMax(j) = rez{j}.maxcoef;
        end
        
        
        % find which stretching parameter had the best score
        [value,b] = min(xcorrMax);

        % select the results for this best stretching parameter and output
        % them. If there were no values computed for this barcode, we don't
        % save anything.
        if ~isnan(value)
            rezMaxM{idx} = rez{b};
            bestBarStretch(idx) = stretchFactors(b);
            bestLength(idx) = round(lenBarTested*stretchFactors(b));
            rezMaxM{idx}.bestBarStretch = bestBarStretch(idx);
            rezMaxM{idx}.bestLength = bestBarStretch(idx);
        else
            rezMaxM{idx} = rez{1};
            bestBarStretch(idx) = nan;
            bestLength(idx) = nan;   
        end
end

end

