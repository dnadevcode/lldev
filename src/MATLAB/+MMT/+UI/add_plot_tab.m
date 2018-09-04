function [] = add_plot_tab(barcodes, barcodePxRes,bsosStruct,sets)
    tabTitle = 'MMT vs. E';
% 
%     [hTabConsensusImport] = ts.create_tab(tabTitle);
%    hPanelConsensusImport = uipanel(hTabConsensusImport);
% 
%      hAxis = axes(...
%     'Parent', hPanelConsensusImport, ...
%     'Units', 'normalized', ...
%     'Position', [0.1 0.6 0.3 0.3], ...
%     'FontSize', 12);

     title(tabTitle)
     

%    chiSqr = sum((bar1-bar2).^2);
%    chiSqr

    plot(zscore(barcodePxRes),'color','black','linewidth',2)
    hold on
    if bsosStruct.flipTFAtBest==1
        barcodes = fliplr(barcodes);  % TODO: check if it plots well for flipped barcodes
    end
    plot(circshift(zscore(barcodes),[0,-bsosStruct.circShiftAtBest]),'linewidth',2)
    
    xlabel( 'Position (kbp)', 'Fontsize', 12);
    ylabel( 'Intensity profile', 'Fontsize', 12);

    ax = gca;
    ticks = 1:round(length(barcodes)/10):length(barcodes);
    ticksx = floor(ticks*sets.pixelWidth_nm/sets.meanBpExt_nm/1000); % shouldn't be hardcoded, load settings instead for more accurate
    ax.XTick = [ticks];
    ax.XTickLabel = [ticksx];

    legendInfo = {};
    legendInfo{1} = [strcat(['P-S melting map, ' '$C_{\max}=$' num2str(bsosStruct.xcorrAtBest) ])];
    legendInfo{2} = ['Consensus barcode'];


    legend(legendInfo,'interpreter','latex')
end