function [ correctAlignedBar,correctAlignedBit ] = save_correct_alignment(comparisonStructure, barLong,bitLong )
    
    plot(find(bitLong), barLong(find(bitLong))./mean(barLong(logical(bitLong))),'linewidth', 1)
    hold on
    barShort = comparisonStructure.bestStretchedBar;
    bitShort = comparisonStructure.bestStretchedBitmask;

    
    orientation = comparisonStructure.or;
    maxcoef = comparisonStructure.maxcoef;
    pos =  comparisonStructure.pos;
   
    lenDif = length(barLong)-length(barShort);
    if lenDif < 0
        barShort(pos+lenDif:pos-1) = [];
        bitShort(pos+lenDif:pos-1) = [];

        
        % if experiment is longer than the theory, flip them places..
        if orientation(1) == 2
        	barShort = fliplr(barShort);
            bitShort = fliplr(bitShort);
            pos = length(barLong)+lenDif-1;
        else
            pos = length(barLong)-(comparisonStructure.pos(1)+lenDif)+2;
        end
    else
         if orientation(1) == 2
        	barShort = fliplr(barShort);
            bitShort = fliplr(bitShort);
         end
    end  
% 
%     import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
%     [xcorrs, ~, ~] = get_no_crop_lin_circ_xcorrs(barShort,barLong, bitShort, bitLong);
%     xcorrMax = max(xcorrs(:));
%     [maxcoef,pos,orientation] = CBT.Hca.UI.Helper.get_best_parameters(xcorrs,length(barShort) );
                     
    fitPositions = mod(pos(1):pos(1)+length(barShort)-1,length(barLong)+1);
    [~,b] = find(fitPositions==0,1,'first');
    if ~isempty(b)
        fitPositions(b:end)=fitPositions(b:end)+1;
    end
    barFit = barLong(fitPositions);
    bitLong = bitLong(fitPositions);
    m1 = mean(barFit(logical(bitShort)));
    s1= std(barFit(logical(bitShort)));

    m2 = mean(barShort(logical(bitShort)));
    s2= std(barShort(logical(bitShort)));

 %   permute(barShort,fitPositions')
% fitPositions
 correctAlignedBar = circshift(barShort,[0,fitPositions(1)-1]);
correctAlignedBit= circshift(bitShort,[0,fitPositions(1)-1]);
%  Y = reshape(fitPositions.*barShort,size(barShort));
%     correctAlignedBar = barShort(fitPositions);
%     correctAlignedBit = bitShort(fitPositions);
    
%     if ~isempty(b)
%         fitPositions = [fitPositions(1:b-1) nan fitPositions(b:end)];
%         barShort = [barShort(1:b-1) nan barShort(b:end)];
% 
%        % barFit = [barFit(1:b-1) barFit(b:end) nan ];
%     end
    plot(find(correctAlignedBit), correctAlignedBar(find(correctAlignedBit))/m2,'linewidth', 1)

    %plot(fitPositions,(barShort/m2),'linewidth', 1)
   % xlim([pos(1) pos(1)+length(barShort)-1 ])

%     title(strcat(['$\hat C=$' num2str(maxcoef(1),'%0.2f')]),'Interpreter','latex');
%     if length(barOne)< length(barTwo)
%         legend({num2str(selectedIndices(1)),num2str(selectedIndices(2)) });
%     else
%         legend({num2str(selectedIndices(2)),num2str(selectedIndices(1)) });
%     end
%         

end

