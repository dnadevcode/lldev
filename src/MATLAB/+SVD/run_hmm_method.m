function run_hmm_method( seq1, seq2, axMtx, axAlign, axComp, tabRes )
%RUN_HMM_METHOD Summary of this function goes here
%   Detailed explanation goes here
    import SVD.Core.hmmsearch;
    res = hmmsearch({seq1}, {seq2});
    
    import SVD.UI.Plot.alignmentMatrix;
    alignmentMatrix(res{1}, seq1, seq2, axMtx);
    
    import SVD.UI.Plot.alignment;
    alignment(res{1}, seq1, seq2, axAlign);
    
    import SVD.UI.Plot.comparison
    comparison(res{1}, seq1, seq2, axComp);

    import SVD.UI.hmm_table
    hmm_table(res{1}, seq1, seq2, tabRes)
    
end

