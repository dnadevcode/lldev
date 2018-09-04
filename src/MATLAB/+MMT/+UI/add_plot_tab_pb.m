function [] = add_plot_tab_pb(ts, bar, barcodePxRes,kbpPerPixel)
    tabTitle = 'MMT PB vs. E';

    
    [hTabConsensusImport, tabNumConsensusImport] = ts.create_tab(tabTitle);
   hPanelConsensusImport = uipanel(hTabConsensusImport);

     hAxis = axes(...
    'Parent', hPanelConsensusImport, ...
    'Units', 'normalized', ...
    'Position', [0.1 0.6 0.3 0.3], ...
    'FontSize', 12);

     title(tabTitle)
     
     
    % if barcode was z-scored (only for old-consensus stuff), convert back to the mean and std of exp
    % barcode. 
%     if mean(bar) < 0.1
%         bar = bar*std(barcodePxRes)+mean(barcodePxRes);
%     end
%             
    bar1 = barcodePxRes/sum(barcodePxRes);

    
    bar2 = bar;
    

    [cc1,cc2] = Comparison.cc_fft(zscore(bar1),zscore(bar2));
    [a,b] = max([cc1 cc2]);

%     h = figure, %plot(bar(6:end-6)/sum(bar(6:end-6)),'color','black','linewidth',1)
%     hold on
    plot(hAxis,bar1,'color','black','linewidth',2)
    hold on
    %plot(zscore(barcode(6:end-6)))
    if b>length(cc1)
        fff = circshift(fliplr(bar2),[0,(b-length(cc1))]);
        plot(hAxis,fff,'color','blue','linewidth',1)
    else
        fff = circshift(bar2,[0,-b]);
        plot(hAxis,fff,'color','blue','linewidth',1)

    end
            
%      plot(hAxis, bar, 'black', 'Linewidth', 2);
     xlabel(hAxis, 'Position (kbp)', 'Fontsize', 12);
     ylabel(hAxis, 'Intensity profile', 'Fontsize', 12);

    ax = gca;
    ticks = 1:50:length(bar);
    ticksx = floor(ticks*kbpPerPixel/1000); % shouldn't be hardcoded//
    ax.XTick = [ticks];
    ax.XTickLabel = [ticksx];

    legendInfo = {};
    legendInfo{1} = ['Consensus'];
    legendInfo{2} = [strcat(['P-B melting map, ' '$C_{\max}=$' num2str(a) ])];

    legend(legendInfo,'interpreter','latex')
end