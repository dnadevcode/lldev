function [hPlotAxes] = plot_curves_in_tabs(hTabGroup, intensityCurves, tabTitles, plotTitles)
    if nargin < 4
        plotTitles = tabTitles;
    end

    % -- create ui elements and present data --
    % create tabgroup to contain the tabs
    numCurves = length(intensityCurves);
    hPlotAxes = gobjects(numCurves, 1);
    for curveNum = 1:numCurves
        % create new tab and plot unscaled barcode on it
        tabTitle = tabTitles{curveNum};
        hTab = uitab(hTabGroup, 'Title', tabTitle);
        hTabPanel = uipanel('Parent', hTab);
        hPlotAxis = axes('Parent', hTabPanel);
        plot(hPlotAxis, intensityCurves{curveNum});

        % add descriptive title above plot

        title(hPlotAxis, plotTitles{curveNum}, 'Interpreter', 'none');
        hPlotAxes(curveNum) = hPlotAxis;
    end
end