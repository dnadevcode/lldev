function [aborted, ntSeqFilepaths] = try_prompt_nt_seq_filepaths(promptTitle, allowMultiselect, allowDatFileSelection, defaultFilepath)
    if nargin < 1
        promptTitle = [];
    end
    if nargin < 2
        allowMultiselect = [];
    end
    if nargin < 3
        allowDatFileSelection = [];
    end
    if nargin < 4
        defaultFilepath = [];
    end
    if isempty(allowDatFileSelection)
        allowDatFileSelection = true; % TODO: deprecate dat file support
    end
    if isempty(allowMultiselect)
        allowMultiselect = true;
    end
    if isempty(promptTitle)
        if allowMultiselect
            promptTitle = 'Select DNA sequence fasta files';
        else
            promptTitle = 'Select DNA sequence fasta file';
        end
    end
    if allowMultiselect
        multiSelectStr = 'on';
    else
        multiSelectStr = 'off';
    end
    if allowDatFileSelection
        filterSpec = {'*.dat;*.fasta;'};
    else
        filterSpec = {'*.fasta;'};
    end
    if isempty(defaultFilepath)
        import AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        defaultFilepath = appDirpath;
    end

    [ntSeqFilenames, dirpath] = uigetfile(filterSpec, promptTitle, defaultFilepath, 'MultiSelect', multiSelectStr);
    aborted = isequal(dirpath, 0);
    if aborted
        ntSeqFilepaths = cell(0, 1);
    else
        ntSeqFilepaths = fullfile(dirpath, ntSeqFilenames);
    end
    if not(iscell(ntSeqFilepaths))
        ntSeqFilepaths = {ntSeqFilepaths};
    end
end