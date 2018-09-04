function [] = print_figure_image(hFig, printFilepath)
    if nargin < 1
        hFig = gcf();
    else
        hFig = ancestor(hFig, 'figure', 'toplevel');
    end

    if nargin < 2
        timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        defaultPrintDirpath = appDirpath;
        defaultPrintFilename = sprintf('screenshot_%s.png', timestamp);
        defaultPrintFilepath = fullfile(defaultPrintDirpath, defaultPrintFilename);
        printFilepath = uiputfile({'*.png'}, 'Save screenshot file', defaultPrintFilepath);
    end

    tempPPM = get(hFig, 'PaperPositionMode');
    set(hFig, 'PaperPositionMode', 'auto');
    print(hFig, '-dpng', '-r0', printFilepath);
    set(hFig, 'PaperPositionMode', tempPPM);
end