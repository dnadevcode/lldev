function [aborted, ntSeq, seqFastaHeader, seqFilepath, seqIdxInFile] = try_import_fasta_nt_seq(fastaFilepath)
    ntSeq = '';
    seqFastaHeader = '';
    seqFilepath = '';
    seqIdxInFile = NaN;

    if nargin < 1
        import NtSeq.Import.UI.try_prompt_nt_seq_filepaths;
        [aborted, fastaFilepaths] = try_prompt_nt_seq_filepaths('Select theory sequence file', false, false);
        aborted = aborted || isempty(fastaFilepaths);
        if aborted
            return;
        end
        fastaFilepath = fastaFilepaths{1};
    end

    import NtSeq.Import.import_fasta_nt_seqs;
    fastaFilepaths = {fastaFilepath};
    [ntSeqs, seqFastaHeaders, seqFilepaths, seqIdxsInFile] = import_fasta_nt_seqs(fastaFilepaths);
    aborted = isempty(ntSeqs);
    if aborted
        ntSeq = '';
        return;
    end
    aborted = isempty(ntSeq);
    seqFastaHeader = seqFastaHeaders{1};
    ntSeq = ntSeqs{1};
    seqFilepath = seqFilepaths{1};
    seqIdxInFile = seqIdxsInFile(1);
end