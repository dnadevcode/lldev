function [theorySequence, theoryName] = prompt_dna_sequence()
    theorySequence = '';
    theoryName = '';
    % Get the theory sequence from the user.
    % e.g. 'T4.fasta'

    import NtSeq.Import.UI.try_prompt_nt_seq_filepaths;
    [aborted, fastaFilepaths] = try_prompt_nt_seq_filepaths('Select theory sequence file', false, false);
    if aborted || isempty(fastaFilepaths)
        fprintf('Must provide a sequence in fasta format\n');
        return;
    end
    fastaFilepath = fastaFilepaths{1};

    fprintf('Loading sequence.../n');
    import NtSeq.Import.import_fasta_nt_seqs;
    [ntSeqs] = import_fasta_nt_seqs(fastaFilepaths);
    theorySequence = ntSeqs{1};
    [~, theoryName, ~] = fileparts(fastaFilepath);
end