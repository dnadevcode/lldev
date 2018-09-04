function [ results, scores ] = hmmsearch( barcodes, comparison_barcodes )
%hmmsearch Hidden Markov model based structural variation search.
%   Inputs should be zscaled barcodes (double vectors) in a cell.
%   e.g. {[-0.1 0 -0.5 1], [0 1 -1 -2]}.
%       barcodes: 
%           barcodes that will be turned into HMM profiles
%           if there are no comparison_barcodes they will be 
%           searched against themselves
%       comparison_barcodes (optional):
%           barcodes to be used as the HMM observation sequence.
    
    import SVD.Core.HMM.viterbi;        
    import SVD.Core.HMM.profile_build;
    import Barcoding.Helpers.discretize_barcodes;

    barcodes = cellfun(@zscore, barcodes, 'UniformOutput', 0);
    d_bcs1 = cellfun(@discretize_barcodes, barcodes, 'UniformOutput', 0);
    p_bcs1 = cellfun(@profile_build, d_bcs1, 'UniformOutput', 0);

    if nargin > 1
        comparison_barcodes = cellfun(@zscore, comparison_barcodes, 'UniformOutput', 0);
        d_bcs2 = cellfun(@discretize_barcodes, comparison_barcodes, 'UniformOutput', 0);
    else
        d_bcs2 = d_bcs1;
    end
    
    results{length(d_bcs1), length(d_bcs2)} = [];
    scores{length(d_bcs1), length(d_bcs2)} = [];
    for i = 1:length(d_bcs1)
        for j = 1:length(d_bcs2)
            [results{i, j}, scores{i, j}] = viterbi(p_bcs1{i}, d_bcs2{j});
        end
    end
end

