function [] = add_plot_thresh_tab(ts,  placedTot,placedCor,contigSizeAllPos,lengthBarcode, kbpPerpx, titlet)
    if isempty(ts)
        set(0,'defaulttextinterpreter','latex')

        hFig = figure(...
            'Name', 'Contig Assembly GUI', ...
            'Units', 'normalized', ...
            'OuterPosition', [0.05 0.05 0.9 0.9], ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'ToolBar', 'none' ...
        );

        hMenuParent = hFig;
        hPanel = uipanel('Parent', hFig);
        import Fancy.UI.FancyTabs.TabbedScreen;
        ts = TabbedScreen(hPanel);

        hTabCA = ts.create_tab('CA');
        ts.select_tab(hTabCA);
        hPanelCA = uipanel('Parent', hTabCA);
        tsCA = TabbedScreen(hPanelCA);
    end
    
    tabTitle = titlet;
            
    % create a tab for ploting consensus barcode

    [hTabConsensusImport, tabNumConsensusImport] = ts.create_tab(tabTitle);
    hPanelConsensusImport = uipanel(hTabConsensusImport);

     hAxis = axes(...
    'Parent', hPanelConsensusImport, ...
    'Units', 'normalized', ...
    'Position', [0.1 0.6 0.3 0.3], ...
    'FontSize', 12);

     title(tabTitle)
     
     resMat = placedTot./lengthBarcode;
    
     mMean = mean(transpose(resMat));
     sStd =  std(transpose(resMat));
   
    errorbar(hAxis,contigSizeAllPos,mMean,sStd) 
    hold on   
    resMat2 = placedCor./placedTot;
    mMean2 = mean(transpose(resMat2));
    sStd2 =  std(transpose(resMat2));
    errorbar(hAxis,contigSizeAllPos,mMean2,sStd2) 
    legend(hAxis,{'number of placed/total','number of correctly placed/number of placed' },'Location', 'southeast')
    xlabel(hAxis,'Contig size (bp)')
    ylabel(hAxis,'Ratio')
   
   % ax = gca;
%     ticks = 1:50:lengthBarcode;
%     ticksx = floor(ticks*kbpPerpx/1000); % shouldn't be hardcoded//
%     hAxis.XTick = [ticks];
%     hAxis.XTickLabel = [ticksx];
% 
%     legendInfo = {};
%     legendInfo{1} = ['Consensus'];
%     legend(legendInfo)
end