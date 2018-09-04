function [ output_args ] = hmm_table( vitResults, barcode1, barcode2, tab )
%HMM_TABLE Summary of this function goes here
%   Detailed explanation goes here
    import SVD.Core.HMM.parse_vtrace;
    res_table = parse_vtrace(vitResults);
    
    import SVD.Core.Stats.compute_hit_pvals
    [pVals, CCs] = compute_hit_pvals(barcode1, barcode2, vitResults);

    set(tab, 'data', [res_table [CCs{:}]' pVals'])
    set(tab, 'ColumnName', {'Px barcode|Start', 'Px barcode|End', 'Profile barcode|Start', 'Profile barcode|End', 'Hit CC', 'Hit p-value'})
    set(tab, 'Position', [20 20 500 400]);

end

