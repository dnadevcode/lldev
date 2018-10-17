function [] = get_display_results(hcaSessionStruct,sets)

    markers = ['o';'s';'x';'+';'d';'v'];

   % hcaSessionStruct.comparisonStructure
    lengthBorders = cumsum(cellfun(@length,hcaSessionStruct.theoryGen.theoryBarcodes));

    %len1=length(hcaSessionStruct.comparisonStructure);

     
%              
%             indx=1;
% 
%             mm =[];
%             for i=1:length(hcaSessionStruct.comparedStructure);
%                 maxcoef = cell2mat(cellfun(@(x) x.maxcoef,hcaSessionStruct.comparedStructure{i},'UniformOutput',0));
%                 mm= [mm max(maxcoef(:))];
%             end
% 
%             [u,indx] = max(mm);
%             hcaSessionStruct.bestCh = hcaSessionStruct.theoryGen.theoryNames{indx};
%             hcaSessionStruct.bestCoef = u;
% 
%             hcaSessionStruct.comparisonStructure = hcaSessionStruct.comparedStructure{indx};
%             hcaSessionStruct.comparisonStructureFiltered = hcaSessionStruct.comparedStructureFiltered{indx};

    
    
    len1=length(hcaSessionStruct.comparisonStructure);

    if sets.barcodeConsensusSettings.aborted==0
        len1=len1-1;
    end
    fig1 = figure;
    subplot(2,2,1);hold on;
	maxcoef = cell2mat(cellfun(@(x) x.maxcoef,hcaSessionStruct.comparisonStructure,'UniformOutput',0));
    
    p = plot(maxcoef(1:len1,:),1:len1,'ob');
    
    p(1).Marker = markers(1);
    p(2).Marker = markers(2);
    p(3).Marker = markers(3);

    if sets.filterSettings.filter==1
      	maxcoefFiltered = cell2mat(cellfun(@(x) x.maxcoef,hcaSessionStruct.comparisonStructureFiltered,'UniformOutput',0));
    	p2 = plot(maxcoefFiltered(1:len1,:),1:len1,'or');
        p2(1).Marker = markers(4);
        p2(2).Marker = markers(5);
        p2(3).Marker = markers(6);
    end
    
    if  sets.barcodeConsensusSettings.aborted==0
        plot([0.1:0.1:1], 0.5+repmat(len1,10,1))
        p3 = plot(maxcoef(len1+1,:),len1+1,'ob');
        p3(1).Marker = markers(1);
        p3(2).Marker = markers(2);
        p3(3).Marker = markers(3);
        if sets.filterSettings.filter==1
            p4 = plot(maxcoefFiltered(len1+1,:),len1+1,'or');
            p4(1).Marker = markers(4);
            p4(2).Marker = markers(5);
            p4(3).Marker = markers(6);
        end
    end
    
   % plot(repmat(mean(maxCorCoefs(:,1)),1,length(hcaSessionStruct.comparisonStructure)),1:length(hcaSessionStruct.comparisonStructure),'r')
   % legend({'barcodes max match score','mean match score'},'Location','sw')
    ylabel('Barcode nr.','Interpreter','latex')
    xlabel('Maximum match score','Interpreter','latex')
    xlim([0.5 1])
    ylim([0,len1+2])
    legend({'$\hat C$','$C_2$','$C_3$','filtered $\hat C$','filtered $C_2$','filtered $C_3$','consensus line'},'Location','sw','Interpreter','latex')

    subplot(2,2,2),
    

    pos = cell2mat(cellfun(@(x) x.pos,hcaSessionStruct.comparisonStructure,'UniformOutput',0));

    p3 = plot(pos(1:len1,:),1:len1,'ob');
    p3(1).Marker = markers(1);
    p3(2).Marker = markers(2);
    p3(3).Marker = markers(3);
    hold on
    
    if sets.filterSettings.filter==1
        posFiltered = cell2mat(cellfun(@(x) x.pos,hcaSessionStruct.comparisonStructureFiltered,'UniformOutput',0));
    	p4 = plot(posFiltered(1:len1,:),1:len1,'or');
        p4(1).Marker = markers(4);
        p4(2).Marker = markers(5);
        p4(3).Marker = markers(6);
    end
    
    if  sets.barcodeConsensusSettings.aborted==0
        
        plot([0:100:100000], 0.5+repmat(len1,length(0:100:100000),1))
        
        p3 = plot(pos(end,:),len1+1,'ob');
        p3(1).Marker = markers(1);
        p3(2).Marker = markers(2);
        p3(3).Marker = markers(3);
        if sets.filterSettings.filter == 1
            p4 = plot(posFiltered(end,:),len1+1,'or');
            p4(1).Marker = markers(4);
            p4(2).Marker = markers(5);
            p4(3).Marker = markers(6);
        end
    end
    plot(lengthBorders,zeros(1,length(lengthBorders)),'x')
    
    ax = gca;
    pxPerBp = sets.barcodeConsensusSettings.prestretchPixelWidth_nm/sets.barcodeGenSettings.meanBpExt_nm;
%     ticks = 1:1E4:length(hcaSessionStruct.theoryGen.theoryBarcodes{1});
%     ticksx = floor(ticks/1000);
%     ax.XTick = [ticks];
%     ax.XTickLabel = [ticksx];
    xlabel('Best position (px)','Interpreter','latex')
    
    
    ylabel('Barcode nr.','Interpreter','latex')
  %  xlabel('best position (pixel)','Interpreter','latex')
    legend({'$\hat C$','$C_2$','$C_3$','filtered $\hat C$','filtered $C_2$','filtered $C_3$'},'Location','sw','Interpreter','latex')
    ylim([0,len1+2])

    orientation = cell2mat(cellfun(@(x) x.or,hcaSessionStruct.comparisonStructure,'UniformOutput',0));

    [dd,ii] =max(maxcoef(:,1));
  
%     
%     import CBT.Hca.Export.plot_comparison_exp_vs_exp;
%     plot_comparison_exp_vs_exp([4,5],hcaSessionStruct.comparisonStructure   )
%        

    % Here take all
    if size(hcaSessionStruct.theoryGen.theoryBarcodes,2)>size(hcaSessionStruct.theoryGen.theoryBarcodes,1)
        bar = cell2mat(hcaSessionStruct.theoryGen.theoryBarcodes);
        barBit = cell2mat(hcaSessionStruct.theoryGen.bitmask);
    else
        bar = cell2mat(hcaSessionStruct.theoryGen.theoryBarcodes');
        barBit = cell2mat(hcaSessionStruct.theoryGen.bitmask');     
    end
   % bar = hcaSessionStruct.theoryGen.theoryBarcodes{1};
   % barBit = hcaSessionStruct.theoryGen.bitmask{1};
    
    b1 = hcaSessionStruct.comparisonStructure{ii}.bestStretchedBar;
    b1Bit =hcaSessionStruct.comparisonStructure{ii}.bestStretchedBitmask;
    
    subplot(2,2,3), hold on

    if length(bar)>length(b1)
        import CBT.Hca.Export.plot_comparison;
        plot_comparison(ii,dd,len1,pos,orientation,b1, b1Bit,bar,barBit,hcaSessionStruct )
    %    plot_comparison_vs_theory(len1,ii,hcaSessionStruct.theoryGen,hcaSessionStruct.comparisonStructure, hcaSessionStruct.names, 'Unfiltered comparison'  )
    else       
    	CBT.Hca.Export.plot_theory_vs_experiment(bar,barBit,b1,b1Bit,orientation,pos,dd,hcaSessionStruct.names{ii},'theory','Unfiltered barcode')
    end
    subplot(2,2,4);hold on

    if sets.filterSettings.filter==1
        orientation = cell2mat(cellfun(@(x) x.or,hcaSessionStruct.comparisonStructureFiltered,'UniformOutput',0));

        [dd,ii] =max(maxcoefFiltered(:,1));
%         bar = hcaSessionStruct.theoryGen.theoryBarcodes{1};
%         barBit = hcaSessionStruct.theoryGen.bitmask{1};

        b1 = hcaSessionStruct.comparisonStructureFiltered{ii}.bestStretchedBar;
        b1Bit =hcaSessionStruct.comparisonStructureFiltered{ii}.bestStretchedBitmask;
   
        if length(bar)>length(b1)
            import CBT.Hca.Export.plot_comparison;
            plot_comparison(ii,dd,len1,pos,orientation,b1, b1Bit,bar,barBit,hcaSessionStruct )
        %    plot_comparison_vs_theory(len1,ii,hcaSessionStruct.theoryGen,hcaSessionStruct.comparisonStructure, hcaSessionStruct.names, 'Unfiltered comparison'  )
        else
            CBT.Hca.Export.plot_theory_vs_experiment(bar,barBit,b1,b1Bit,orientation,pos,dd,hcaSessionStruct.names{ii},'theory','Filtered barcode')
        end

    end
         
%         % include case when theory is shorter than experiment:
%         if length(bar) < length(b1)
%             tempb = b1;
%             tempbit=b1Bit;
%             b1 = bar;
%             b1Bit = barBit;
%             bar = tempb;
%             barBit = tempbit;
%         end
%     
%         if orientation(ii,1) == 2
%             b1 = fliplr(b1);
%             b1Bit = fliplr(b1Bit);
%         end
% 
% 
% 
%     
%         fitPositions = posFiltered(ii,1):posFiltered(ii,1)+length(b1)-1;
%         
% %         
% %        if sum(fitPositions<=0) > 1
% %             indx = find(fitPositions<=0);
% %             indx = length(bar)-fliplr(indx);
% %             fitPositions(find(fitPositions<=0)) = indx;     
% %        end
%        
%         barFit = bar(fitPositions);
%         barBit = barBit(fitPositions);
%         m1 = mean(barFit(logical(b1Bit)));
%         s1= std(barFit(logical(b1Bit)));
% 
%         m2 = mean(b1(logical(b1Bit)));
%         s2= std(b1(logical(b1Bit)));
% 
%         plot(fitPositions,((b1-m2)/s2) *s1+m1)
%         hold on
%         plot(fitPositions,barFit)
%         xlim([posFiltered(ii,1) posFiltered(ii,1)+length(b1)-1 ])
% %         ax = gca;
% %         %pxPerBp = sets.barcodeConsensusSettings.prestretchPixelWidth_nm/sets.barcodeGenSettings.meanBpExt_nm;
% %         ticks = fitPositions(1):30:fitPositions(end);
% %         ticksx = floor(ticks);
% %         ax.XTick = [ticks];
% %         ax.XTickLabel = [ticksx/1000];
%         xlabel('Position (px)','Interpreter','latex')
%         ylabel('Rescaled to theoretical intesity','Interpreter','latex')
%         if ii <= len1
% %             name = strcat([hcaSessionStruct.names{ii}]);
% %             name = strrep(name,'_','');
% %             name = strrep(name,'$','');
%             name = num2str(ii);
%          %   name = strrep(name,'kymograph.tif','');
%         else
%             name = 'consensus';
%         end
%        title(strcat(['Filtered barcode ']),'Interpreter','latex');
% 
%         legend({strcat(['$\hat C_{' name '}=$' num2str(dd,'%0.2f')]),hcaSessionStruct.theoryGen.theoryNames{1}},'Interpreter','latex')
% 
%     end
% 

%    legend({'Theory barcode','filtered one frame experiment'})

   disp( strcat(['Number of timeframes for the unfiltered barcodes were = ' num2str(sets.timeFramesNr)]));
   if sets.filterSettings.filter==1
        disp( strcat(['Number of timeframes for the filtered barcodes were = ' num2str(sets.filterSettings.timeFramesNr)]));
   end
   
    assignin('base','hcaSessionStruct',hcaSessionStruct)
    
  %  cache('hcaSessionStruct') = hcaSessionStruct ;
  
end