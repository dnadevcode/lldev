function [cache] = create_movie_import_tab(hMenuParent, tsHCC, tabTitle,cache )
    % create_import_tab 
    if nargin < 4
        cache = containers.Map();
    end

    % create main tab for the analysis
    hTabKymoImport = tsHCC.create_tab(tabTitle);
    tsHCC.select_tab(hTabKymoImport);
    hPanelKymoImport = uipanel(hTabKymoImport);

    % import kymographs
    import Fancy.UI.Templates.launch_movie_import_ui;
    [lm,cache] = launch_movie_import_ui(hMenuParent,hPanelKymoImport,tsHCC,cache);
end

