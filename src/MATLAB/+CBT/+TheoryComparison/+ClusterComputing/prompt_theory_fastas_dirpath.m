function [aborted, dirpath] = prompt_theory_fastas_dirpath()
    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    defaultTheoryDirpath = appDirpath;
    dirpath = uigetdir(defaultTheoryDirpath, 'Select theory directory');
    aborted = isequal(dirpath, 0);
    if aborted
        dirpath = '';
        return;
    end
end