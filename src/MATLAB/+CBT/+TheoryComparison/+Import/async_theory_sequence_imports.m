function async_theory_sequence_imports(theorySequenceFilepaths, on_load_start, on_load_end)
    import CBT.TheoryComparison.Import.async_theory_sequence_import;

    numTheorySequences = length(theorySequenceFilepaths);
    for theorySequenceNum = 1:numTheorySequences
        async_theory_sequence_import(theorySequenceFilepaths{theorySequenceNum}, on_load_start, on_load_end);
    end
end