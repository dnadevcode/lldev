function [hAxes, hTabPanels, hTabs] = create_tabs_panels_axes(tabgroupHandle, tabTitleTexts)
    numAxes = length(tabTitleTexts);
    hTabs = gobjects(numAxes, 1);
    hTabPanels = gobjects(numAxes, 1);
    hAxes = gobjects(numAxes, 1);
    for axisNum = 1:numAxes
        tabTitleText = tabTitleTexts{axisNum};

        hTab = uitab('Parent', tabgroupHandle, 'Title', tabTitleText);
        hPanel = uipanel('Parent', hTab);
        hAxis = axes('Parent', hPanel);

        hTabs(axisNum) = hTab;
        hTabPanels(axisNum) = hPanel;
        hAxes(axisNum) = hAxis;
    end
end