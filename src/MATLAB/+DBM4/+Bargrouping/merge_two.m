function [twoBars,shift, score,scoreOverlap,isflip,curSF] = merge_two(oS,bars)

%        pB = oS(1,2).pA; % pos A
%         pA = oS(1,2).pB; % pos B
%         pO = oS(1,2).or; % orientation
%         lenA = length(bars{1}.rawBarcode);
%         lenB = length(bars{2}.rawBarcode);
% 
%         stIdx = min(pA,pB);
%         pA  = pA-stIdx+1;
%         pB = pB-stIdx+1;
%         stopIdx =max(pA+lenA-1,pB+lenB-1);
% 
%         % 
%         twoBars = nan(2,stopIdx-stIdx+1);
% 
%         tmpBar = bars{1}.rawBarcode;
% 
%         tmpBar2 = bars{2}.rawBarcode;
%         tmpBar(~bars{1}.rawBitmask) = nan;
% 
%         tmpBar2(~bars{2}.rawBitmask) = nan;
%         if pO==-1
%             tmpBar = fliplr(tmpBar);
%         end
%         twoBars(1,pA:pA+lenA-1)= tmpBar;
%         twoBars(2,pB:pB+lenB-1)= tmpBar2;
% 
%         shift = [pA;pB];
% 
%         score= oS(1,2).score;

% 
isflip = 0;
       pA = oS(2,1).pA; % pos A
        pB = oS(2,1).pB; % pos B
        pO = oS(2,1).or; % orientation
        curSF = oS(2,1).bestBarStretch;

        % 

        tmpBar = bars{1}.rawBarcode;

        tmpBar2 = bars{2}.rawBarcode;
        tmpBar(~bars{1}.rawBitmask) = nan;

        lBar2 = length(tmpBar2);
        tmpBar2 = imresize(tmpBar2,[1 lBar2*curSF]);
        tmpBit2 = imresize(bars{2}.rawBitmask,[1 lBar2*curSF]);

        tmpBar2(logical(~tmpBit2)) = nan;
        if pO==-1
            tmpBar2 = fliplr(tmpBar2);
            isflip = 1;
        end

        lenA = length(tmpBar);
        lenB = length(tmpBar2);

        stIdx = min(pA,pB);
        pA  = pA-stIdx+1;
        pB = pB-stIdx+1;
        stopIdx =max(pA+lenA-1,pB+lenB-1);

        twoBars = nan(2,stopIdx-stIdx+1);


        twoBars(1,pA:pA+lenA-1)= tmpBar;
        twoBars(2,pB:pB+lenB-1)= tmpBar2;

        shift = [pA;pB];

        score = oS(2,1).score;
        scoreOverlap = oS(2,1).fullscore;

        % also give score for full overlap
%      
end

