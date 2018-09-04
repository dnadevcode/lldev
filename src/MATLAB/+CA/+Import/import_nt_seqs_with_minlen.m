function [ntSeqs, fastaHeaders] = import_nt_seqs_with_minlen(minimalAllowedNtSeqLen, contigFilepaths)
    import NtSeq.Import.import_fasta_nt_seqs;
    [ntSeqs, fastaHeaders] = import_fasta_nt_seqs(contigFilepaths);

    seqLens = cellfun(@length, ntSeqs);
    tooShortMask = (seqLens < minimalAllowedNtSeqLen);

    validSeqsMask = not(tooShortMask);
    ntSeqs = ntSeqs(validSeqsMask);
    fastaHeaders = fastaHeaders(validSeqsMask);
end