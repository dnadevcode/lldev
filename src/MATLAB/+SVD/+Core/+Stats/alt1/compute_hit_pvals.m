function [ pVals, CCs ] = compute_hit_pvals( queryBarcode, targetBarcode, vtrace )
%COMPUTE_HIT_PVALS Summary of this function goes here
%   Detailed explanation goes here
    import SVD.Core.Stats.local_align_cc_pvals
    import SVD.Core.HMM.parse_vtrace
    
    randBarcodeFunc = @(x, y) cellfun(@SVD.Core.Stats.randWalkBc, repmat({x}, y, 1), 'UniformOutput', 0);    
    
    hits = parse_vtrace(vtrace);
    [pVals, CCs] = local_align_cc_pvals(queryBarcode, targetBarcode, hits, randBarcodeFunc );

end

