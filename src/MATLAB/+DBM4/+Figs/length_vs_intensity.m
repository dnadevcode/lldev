function [] = length_vs_intensity(kymoStatsTable,axP)

% kymoStatsTable = dbmStruct.kymoCells.kymoStatsTable;

DNAExtensions =kymoStatsTable.meanOfFramewiseMoleculeExts;
intensities = cellfun(@(x) mean(x),kymoStatsTable.meanFramewiseMoleculeIntensity)-kymoStatsTable.meanNonMainMoleculePixelIntensity;

% draw a box for lambdas

% f = figure
t = tiledlayout(axP,1,1);
ax = axes(t)
%strings = {'good barcode','maybe','bad barcode','lambda'};
strings = {'lambda','non-lambda'};

labels = arrayfun(@(x) strings{1},1:length(intensities),'un',false);
% labels{1} = strings{2};
%             labels{9} = strings{3};

color = {[0, 0.65, 0.95],'cyan','none'}; % magenta, cyan, grey
sz = [40,30,30];
linewidth = [0.5, 1.5,1.5];
alpha = [0.6,0.6,0.6];
ax.XLim = [0,max(DNAExtensions)+10];
ax.YLim = [0,max(intensities)*1.1];
hold(ax,'on')

for i = 1:length(strings)
    xData = DNAExtensions(strcmp(labels,strings{i}));
    yData = intensities(strcmp(labels,strings{i}));
    s = scatter(ax,xData,yData,sz(i),...
        'MarkerEdgeColor',color{i},'MarkerFaceColor',color{i},...
        'Linewidth',linewidth(i),...
        'MarkerFaceAlpha',alpha(i),'MarkerEdgeAlpha',alpha(i));
end

% 
s.LineWidth = 1;
s.MarkerEdgeColor = [0.3 0.3 0.3];
s.MarkerFaceColor = 'none';

legend(ax,'lambda','non-lambda','location','southoutside');
xlabel('Extension (px)')
ylabel('Intensity')
title('Length vs intensity plot')
            %legend(app.UIAxes1,'good barcode','maybe','bad barcode','lambda');



end

