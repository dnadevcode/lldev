function [refSeqsFailedImport] = import_fastas(plasmidFastaDirpath, maxNumImports)
    import NCBI.try_prompt_plasmid_fastas_dirpath;
    refSeqsFailedImport = [];
    if (nargin < 1) || isempty(plasmidFastaDirpath)
        [aborted, plasmidFastaDirpath] = try_prompt_plasmid_fastas_dirpath();
    else
        aborted = false;
    end
    if aborted
        return;
    end
    if nargin < 2
        maxNumImports = inf;
    end
    
    dirFastaFiles = feval(@(fs) {fs.name}, dir([plasmidFastaDirpath, filesep(), '*.fasta']))';
    [~, refSeqsImported] = cellfun(@fileparts, dirFastaFiles, 'UniformOutput', false);

    import NCBI.get_latest_complete_bacterial_plasmid_version_info;
    [refSeqs, refSeqsAccessionNumber, refSeqsAccessionVersionNumber, plasmidsDataTable, originalColHeaders] = get_latest_complete_bacterial_plasmid_version_info();

    refSeqsToImport = setdiff(refSeqs, refSeqsImported);

    refSeqsToImport = refSeqsToImport(1:min(maxNumImports, end));

    refSeqsFailedImport = cell(0, 1);
    if plasmidFastaDirpath ~= 0
        fn_on_read_success = @(refSeq, fastaStr) on_read_success(refSeq, fastaStr, plasmidFastaDirpath);
        
        
        import NCBI.get_complete_bacterial_plasmid_fastas;
        [successStatuses] = get_complete_bacterial_plasmid_fastas(refSeqsToImport, fn_on_read_success);
        refSeqsFailedImport = refSeqsToImport(not(successStatuses));
    end
    
    function importSuccessTF = on_read_success(refSeq, fastaStr, plasmidFastaDirpath)
        fastaFilename = [refSeq, '.fasta'];
        fastaFilepath = fullfile(plasmidFastaDirpath, fastaFilename);
        
        import NtSeq.Import.validate_fasta_str;
        [errorMsg, fastaData] = validate_fasta_str(fastaStr);
        importSuccessTF = isscalar(errorMsg) && (errorMsg == false);
        if importSuccessTF
            try
                fastawrite(fastaFilepath, fastaData);
            catch allExceptions
                importSuccessTF = false;
            end
            % import Fancy.IO.try_write_file;
            % importSuccessTF = try_write_file(fastaFilepath, fastaStr);
        end
    end
end