function [hAxisAB, hAxisA, hAxisB] = plot_dtw_curve_vs_curve(hPanel, accumulatedDistMat, optimalPath, curveA, curveB, labelFactorA, labelFactorB)
    % PLOT_DTW_CURVE_VS_CURVE = Plots two curves, and the cost
    %   matrix
    % Authors:
    %   Erik Lagerstedt (original)
    %   Saair Quaderi
    curveLenA = length(curveA);
    curveLenB = length(curveB);

    if nargin < 6
        labelFactorA = 1;
    end
    if nargin < 7
        labelFactorB = 1;
    end
    
    
    aTickRel = linspace(0, 1, 5);
    aTick = round(curveLenA.*aTickRel);
    aTickLabel = round((curveLenA*labelFactorA).*aTickRel);
    
    bTickRel = linspace(0, 1, 5);
    bTick = round(curveLenB.*bTickRel);
    bTickLabel = round((curveLenB*labelFactorB).*bTickRel);
    
    

    abAxisPosNrm = [0.1 0 0.9 0.85];
    hAxisAB = axes(...
        'Parent', hPanel,...
        'Units', 'normalized',...
        'Position', abAxisPosNrm);
    
    
    axes(hAxisAB);
    imagesc(accumulatedDistMat);
    % axis(axisAB, 'equal');
    % axis(axisAB, 'tight');
    get(hAxisAB, 'Position')
    colormap(hAxisAB, gray);
    set(hAxisAB, ...
        'XTick', [], ...
        'YTick', []);
    hold(hAxisAB, 'on');
    plot(hAxisAB, optimalPath(:,2),optimalPath(:,1),'g','LineWidth',2);
    hold(hAxisAB, 'off');
    
    hAxisA = axes(...
        'Parent', hPanel, ...
        'Units', 'normalized', ...
        'Position', [0.1 0.9 0.9 0.1]);
    imagesc(repmat(curveA(:)', [1, 1]));
    % axis(axisA, 'equal');
    % axis(axisA, 'tight');
    colormap(hAxisA, gray);
    set(hAxisA, ...
        'XTick', aTick, ...
        'XTickLabel', aTickLabel, ...
        'YTick', [], ...
        'YAxisLocation', 'right');    

    
    hAxisB = axes(...
        'Parent', hPanel, ...
        'Units', 'normalized', ...
        'Position', [0 0 0.05 0.85]);
    imagesc(repmat(curveB(:), [1 1]));
    % axis(axisB, 'equal');
    % axis(axisB, 'tight');
    colormap(hAxisB, gray);
    set(hAxisB, ...
        'XTick', [], ...
        'YTick', bTick, ...
        'YTickLabel', bTickLabel, ...
        'YAxisLocation', 'right');
    
end
