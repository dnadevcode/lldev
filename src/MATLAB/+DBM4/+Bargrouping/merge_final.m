function [finalBar] = merge_final(bars,shift,numAvgBars)
    pAFinal = shift(1,1);
    
    pBFinal = [];
    pBFinal(1) = shift(2,1);
    for j=2:numAvgBars-1
        pBFinal(j) = -shift(1,j)+ pBFinal(j-1)+shift(2,j);
    end

    lenbar = zeros(numAvgBars,1);
   for j=1:numAvgBars
        lenbar(j) = length(bars{j}.rawBarcode);
   end
   
   allSt = [pAFinal pBFinal];
   allSt = allSt-min(allSt)+1;
   
   stopIdx =max([allSt+lenbar'-1]);

   finalBar = nan(numAvgBars,stopIdx);
%     pMin = min(shift(:,1));
    for j=1:numAvgBars
        tmpBar = bars{j}.rawBarcode;
        tmpBar(~bars{j}.rawBitmask) = nan;
        finalBar(j,allSt(j):allSt(j)+lenbar(j)-1)= tmpBar;
    end

end
