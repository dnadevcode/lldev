function [bindingExpectedMask, numberOfBindings] = find_sequence_matches(bindingNtSequence, ntSequence)
    %find_sequence_matches 
    
    % input bindingNtSequence, ntSequence
    % output bindingExpectedMask, numberOfBindings
    % edited 24/10/17 by Albertas Dvirnas /- added comments
    
    % This function finds binding positions for the enzimatic labeled barcodes
    
    % this find sequence reverse complement
    bindingSequenceRC = seqrcomplement(bindingNtSequence);
    
    % expected bitmask
    bindingExpectedMask = false(size(ntSequence));
    
    % sequence length 
    bindingSeqLen = length(bindingNtSequence);
    
    % 
    numberOfBindings = 0;
    bpLastStartIdx = length(ntSequence) - bindingSeqLen;
    bpStartIdx = 1;
    while bpStartIdx <= bpLastStartIdx
        idxRange = ((1:bindingSeqLen) - 1) + bpStartIdx;
        if (all(ntSequence(idxRange) == bindingNtSequence) ...
            || all(ntSequence(idxRange) == bindingSequenceRC))
            bindingExpectedMask(idxRange) = true;
            numberOfBindings = numberOfBindings + 1;
            bpStartIdx = bpStartIdx + bindingSeqLen;
        else
            bpStartIdx = bpStartIdx + 1;
        end
    end
end