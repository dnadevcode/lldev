function [  ] = plot_comparison_exp_vs_exp(selectedIndices,comparisonStructure  )


 if length(selectedIndices) == 2
     barOne = comparisonStructure{selectedIndices(1)}.bestStretchedBar;
     bitOne = comparisonStructure{selectedIndices(1)}.bestStretchedBitmask;
     
     for ii=selectedIndices(2:end)
 
        barTwo =comparisonStructure{ii}.bestStretchedBar;
        bitTwo =comparisonStructure{ii}.bestStretchedBitmask;

        if length(barOne)< length(barTwo)
            barShort = barOne;
            bitShort = bitOne;
            barLong = barTwo;
            bitLong = bitTwo;
        else
            barShort = barTwo;
            bitShort = bitTwo;
            barLong = barOne;
            bitLong = bitOne;
        end

        import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
        [xcorrs, ~, ~] = get_no_crop_lin_circ_xcorrs(barShort,barLong, bitShort, bitLong);
        xcorrMax = max(xcorrs(:));
        [maxcoef,pos,orientation] = CBT.Hca.UI.Helper.get_best_parameters(xcorrs,length(barShort) );
        

%                 
        figure, hold on

        if orientation(1) == 2
            barShort = fliplr(barShort);
            bitShort = fliplr(bitShort);
        end

        fitPositions = mod(pos(1):pos(1)+length(barShort)-1,length(barLong));
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
        
        if ~isempty(b)
            fitPositions = [fitPositions(1:b-1) nan fitPositions(b:end)];
            barShort = [barShort(1:b-1) nan barShort(b:end)];
            barFit = [barFit(1:b-1) barFit(b:end) nan ];
        end
        plot(fitPositions,((barShort-m2)/s2) *s1+m1)
        hold on
        plot(fitPositions,barFit)
       % xlim([pos(1) pos(1)+length(barShort)-1 ])
        xlabel('pixel nr.')
        ylabel('Rescaled to theoretical intesity')
        title(strcat(['$\hat C=$' num2str(maxcoef(1),'%0.2f')]),'Interpreter','latex');
        if length(barOne)< length(barTwo)
        	legend({num2str(selectedIndices(1)),num2str(selectedIndices(2)) });
        else
            legend({num2str(selectedIndices(2)),num2str(selectedIndices(1)) });
        end

     end

 end
        

end

