function [] = async_theory_sequence_import(theorySequenceFilepath, on_load_start, on_load_end)
    theoryStruct.sourceFilepath = theorySequenceFilepath;
    on_load_start(false, theoryStruct);
    import NtSeq.Import.try_import_fasta_nt_seq;
    [~, ntSeq] = try_import_fasta_nt_seq(theorySequenceFilepath);
    theoryStruct.sequenceData = ntSeq;
    on_load_end(false, theoryStruct);
end