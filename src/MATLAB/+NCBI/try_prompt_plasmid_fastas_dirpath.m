function [aborted, plasmidFastaDirpath] = try_prompt_plasmid_fastas_dirpath()
    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    defaultPlasmidFastasDir = fullfile(fileparts(appDirpath), 'Data', 'DB', 'fasta', 'plasmids');
    if not(exist(defaultPlasmidFastasDir, 'dir'))
        defaultPlasmidFastasDir = '';
    end
    plasmidFastaDirpath = uigetdir(defaultPlasmidFastasDir, 'Select plasmids fasta directory');
    aborted = isequal(plasmidFastaDirpath, 0);
    if aborted
        plasmidFastaDirpath = '';
    end
end