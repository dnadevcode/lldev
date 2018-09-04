function [successStatuses] = get_complete_bacterial_plasmid_fastas(refSeqs, fn_on_read_success)
    import Fancy.UI.ProgressFeedback.BasicTextProgressMessenger;
    
    progress_messenger = BasicTextProgressMessenger.get_instance();
    fastaPathSpec = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&amp;rettype=fasta&amp;id=%s';
    % fastaPathSpec = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&rettype=fasta&id=%s';
    numRefSeqs = length(refSeqs);
    successStatuses = false(numRefSeqs, 1);
    progress_messenger.init(sprintf(' Attempting import of plasmid fastas...\n'), 0.01);
    for refSeqNum = 1:numRefSeqs
        refSeq = refSeqs{refSeqNum};
        fastaPath = sprintf(fastaPathSpec, refSeq);
        [fastaStr, readSuccess] = urlread(fastaPath);
        if readSuccess
            storageSuccessTF = fn_on_read_success(refSeq, fastaStr);
            successStatuses(refSeqNum) = storageSuccessTF;
        end
        progress_messenger.checkin(refSeqNum, numRefSeqs);
    end
    msgOnCompletion = sprintf('    Attempted import of plasmid fastas\n');
    progress_messenger.finalize(msgOnCompletion);
end