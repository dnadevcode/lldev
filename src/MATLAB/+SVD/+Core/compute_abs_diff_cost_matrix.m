function costMat = compute_abs_diff_cost_matrix(seq1, seq2)
    %Computes cost matrix for two sequences
    % Inputs:
    %   seq1 & seq2: two sequences (real numeric column vectors)
    % Outputs:
    %   costMat: cost matrix with absolute value of differences
    
    if length(seq2) < length(seq1)
        [seqShorter, seqLonger] = deal(seq2, seq1);
    else
        [seqShorter, seqLonger] = deal(seq1, seq2);
    end
    refSeq = seqLonger(:);
    warpedSeq = seqShorter(:);
    
    diffMatrix = bsxfun(@minus, warpedSeq, refSeq');
    costMat = abs(diffMatrix);
end
