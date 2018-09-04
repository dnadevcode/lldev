function [ntSeqs, seqFastaHeaders, seqFilepaths, seqIdxsInFile] = import_fasta_nt_seqs(fastaFilepaths)
    if nargin < 1
        fastaFilepaths = [];
    end
    if isempty(fastaFilepaths)
            import NtSeq.Import.UI.try_prompt_nt_seq_filepaths;
            [~, fastaFilepaths] = try_prompt_nt_seq_filepaths();
    else
        if not(iscell(fastaFilepaths)) && ischar(fastaFilepaths)
            fastaFilepaths = {fastaFilepaths};
        end
    end

    [seqFastaHeaders, ntSeqs] = cellfun(@fastaread, fastaFilepaths, 'UniformOutput', false);

    numFastaFiles = length(fastaFilepaths);
    numSeqsInFiles = zeros(numFastaFiles, 1);
    for fastaFileNum = 1:numFastaFiles
        fastaFileNtSequences = ntSeqs{fastaFileNum};
        fastaFileHeaders = seqFastaHeaders{fastaFileNum};
        isSingleEntry = not(iscell(fastaFileNtSequences));
        if isSingleEntry
            ntSeqs{fastaFileNum} = {fastaFileNtSequences};
            seqFastaHeaders{fastaFileNum} = {fastaFileHeaders};
            numSeqsInFiles(fastaFileNum) = 1;
        else
            numSeqsInFiles(fastaFileNum) = length(fastaFileNtSequences);
        end
    end
    seqFastaHeaders = vertcat(seqFastaHeaders{:});
    
    ntSeqs = vertcat(ntSeqs{:});
    
    seqFileNums = arrayfun(@(fileNum) repmat(fileNum, [numSeqsInFiles(fileNum), 1]),  (1:numFastaFiles)', 'UniformOutput', false);
    seqFileNums = vertcat(seqFileNums{:});
    
    seqFilepaths = fastaFilepaths(seqFileNums);
    
    seqIdxsInFile = arrayfun(@(fileNum) (1:numSeqsInFiles(fileNum))',  (1:numFastaFiles)', 'UniformOutput', false);
    seqIdxsInFile = vertcat(seqIdxsInFile{:});
end