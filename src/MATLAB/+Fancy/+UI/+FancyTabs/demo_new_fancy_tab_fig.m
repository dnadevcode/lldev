function [hFig, hTabgroup, hTabs, fancyTabStructs] = demo_new_fancy_tab_fig(fancyTabTitles, figureName)
    % DEMO_NEW_FANCY_TAB_FIG - a demo function for creating a
    %  figure with tabs where the tabs have fancy functionality
    %  (e.g. shift) that are available when right-clicking
    %
    % Inputs
    %   fancyTabTitles (optional)
    %     cell array of tab titles to be used (defaults to 
    %     demo tab titles if not provided)
    %   figureName (optional)
    %     the name of the figure to be created in which the tabs
    %     will be descendants
    %
    % Outputs:
    %   hFig
    %     handle to the figure that is created
    %   hTabgroup
    %     handle to the parent tabgroup that is created
    %   hTabs
    %     handles to the tabs that are created
    %   fancyTabStructs
    %     structs associated with hTabs
    %
    % Authors:
    %   Saair Quaderi

    import Fancy.UI.FancyPositioning.maximize_figure_or_make_big;
    import Fancy.UI.FancyTabs.add_a_new_fancy_tab;

    if nargin < 1
        fancyTabTitles = {'Demo Tab A'; 'Demo Tab B'; 'Demo Tab C'};
    end
    if nargin < 2
        figureName = 'Demo Fancy Tabs';
    end

    hFig = figure('Name', figureName);
    maximize_figure_or_make_big(hFig);
    hTabgroup = uitabgroup('Parent', hFig);
    numFancyTabs = numel(fancyTabTitles);
    fancyTabStructs = cell(numFancyTabs, 1);
    hTabs = gobjects(numFancyTabs, 1);
    for fancyTabNum = 1:numFancyTabs
        [hTabs(fancyTabNum), fancyTabStructs{fancyTabNum}] = add_a_new_fancy_tab(hTabgroup, fancyTabTitles{fancyTabNum});
    end
end