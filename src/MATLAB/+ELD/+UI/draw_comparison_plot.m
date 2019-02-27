function [ comparisonPlot ] = draw_comparison_plot(resultStructs,moleculeNames)
%function [ comparisonPlot ] = draw_comparison_plot(theoreticalDotPositions,molecule_ends,experimentalDotPositions,experimentalDotVars)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    numMol = numel(resultStructs);
    molIdxs = 1:numMol;

    if nargin < 2 || numel(resultStructs) ~= numel(moleculeNames)
        showNames = false;
    else
        showNames = true;
        moleculeNames = arrayfun(@(molIdx) strrep(moleculeNames{molIdx},'_','\_'), molIdxs, 'UniformOutput',false);
    end
   
    comparisonPlot = figure('visible','off');
%     comparisonPlot = figure;

    emptyCells = cellfun(@isempty,resultStructs);
    if all(emptyCells)
        fprintf('Feature distances could not be computed for any molecule.');
        text(0.5, 0.5, 'Feature distances could not be computed for any molecule.', 'FontSize',12, 'Color','k', ...
        'HorizontalAlignment','Center', 'VerticalAlignment','Middle');
        axis off;
        return;
    end
    
%     labelPositions = cell(numMol+1,1);
    
    resultStructs = resultStructs(~emptyCells);

    theoreticalDotPositions =  resultStructs{1}.theory_dot_positions;
    molecule_ends = resultStructs{1}.theory_molecule_ends;
    
    experimentalDotPositions = arrayfun(@(molIdx) resultStructs{molIdx}.feature_positions_norm, molIdxs, 'UniformOutput',false);
    experimentalDotVars = arrayfun(@(molIdx) resultStructs{molIdx}.feature_position_vars_norm, molIdxs, 'UniformOutput',false);
    
%     moleculeNames = arrayfun(@(molIdx) resultStructs{molIdx}.feature_position_vars_norm, molIdxs, 'UniformOutput',false);
%     moleculeNames{end+1} = [];
%     moleculeNames = circshift(moleculeNames,1);
%     moleculeNames{1} = 'Theory';
%     experimentalDotVars = resultStructs.feature_position_vars_norm;

%     comparisonPlot = figure;
        
    theoreticalDotPositions = theoreticalDotPositions - molecule_ends(1);
%     molecule_ends = molecule_ends - molecule_ends(1);
        
    line([0 molecule_ends(end)-molecule_ends(1)] , [0 0], 'Color','blue');
    
    hold on;
    
%     text(-5,5,'Theory1','HorizontalAlignment','right');
%     text(5,5,'Theory2','HorizontalAlignment','right');
%     text(-5,-5,'Theory3','HorizontalAlignment','right');
%     text(5,-5,'Theory4','HorizontalAlignment','right');
%     text(10,10,'Theory5','HorizontalAlignment','right');
%     
%     text(0,0,'Theory6','HorizontalAlignment','right');
    if showNames
        text(0,2,'Theory','HorizontalAlignment','left','FontSize',8);
    end
%     labelPositions{1} = [-5 , -5];
    
    for feature = 1:length(theoreticalDotPositions)
        line([theoreticalDotPositions(feature) theoreticalDotPositions(feature)] , [-1.5 1.5], 'Color','blue');
    end
    
    for molecule = 1:length(experimentalDotPositions)
        
        experimentalDotPositions{molecule} = experimentalDotPositions{molecule} - molecule_ends(1);
        
        line([experimentalDotPositions{molecule}(1) experimentalDotPositions{molecule}(end)] , [-5*molecule -5*molecule], 'LineStyle', '--' , 'Color','red');
        
        if showNames
            text(experimentalDotPositions{molecule}(1),-5*molecule+2,moleculeNames{molecule},'HorizontalAlignment','left','FontSize',8);
        end
        
        for feature = 1:length(experimentalDotPositions{molecule})
%             line([experimentalDotPositions{molecule}(feature) experimentalDotPositions{molecule}(feature)] , [-2 2]);
            rectangle('Position',[experimentalDotPositions{molecule}(feature) - sqrt(experimentalDotVars{molecule}(feature)) ...
                -(5*molecule)-1.5 ... 
                sqrt(experimentalDotVars{molecule}(feature))*2 ...
                3], 'EdgeColor','red');
        end
        
%         labelPositions{molecule+1} = [experimentalDotPositions{molecule}(1)-5, experimentalDotPositions{molecule}(feature) - sqrt(experimentalDotVars{molecule}(feature))-5 ];
    
    end
    
%     labelImg = insertText(comparisonPlot,labelPositions',moleculeNames,'FontSize',30,'BoxColor',...
%         'w','BoxOpacity',0,'TextColor','black','AnchorPoint','RightBottom');
    
%     set(gca, 'YTick', []);
    axis off;
    set(findobj(gcf, 'type','axes'), 'Visible','off');
    set(gca,'xtick',[],'ytick',[]);
    set(gca,'Color','w');
    
%     barcodeLength = 500;
%     
%     for i=1:length(experimentalDotPositions)
%         experimentalDotPositions{i} = barcodeLength - experimentalDotPositions{i};
%         experimentalDotVars{i} = fliplr(experimentalDotVars{i});
%     end
%     
%     figure, line([molecule_ends(1) molecule_ends(end)] , [0 0], 'Color','blue');
%     
%     hold on;
%     
%     for feature = 1:length(theoreticalDotPositions)
%         line([theoreticalDotPositions(feature) theoreticalDotPositions(feature)] , [-2 2], 'Color','blue');
%     end
%     
%     for molecule = 1:length(experimentalDotPositions)
%         line([theoreticalDotPositions(1) theoreticalDotPositions(end)] , [-5 -5], 'LineStyle', '--' , 'Color','red');
%         
%         for feature = 1:length(experimentalDotPositions{molecule})
% %             line([experimentalDotPositions{molecule}(feature) experimentalDotPositions{molecule}(feature)] , [-2 2]);
%             rectangle('Position',[experimentalDotPositions{molecule}(feature) - sqrt(experimentalDotVars{molecule}(feature)) ...
%                 -(5*molecule)-2 ... 
%                 sqrt(experimentalDotVars{molecule}(feature))*2 ...
%                 4], 'EdgeColor','red');
%         end
%     
%     end

%     set(comparisonPlot,'visible','on')
    
end