function [ pVals, CCs ] = compute_hit_pvals( profileBarcode, pxBarcode, vtrace )
%COMPUTE_HIT_PVALS Summary of this function goes here
%   Detailed explanation goes here

    hits = SVD.Core.HMM.parse_vtrace(vtrace);

    randBarcodeFunction = @(x, y) cellfun(@SVD.Core.Stats.randWalkBc, repmat({x}, y, 1), 'UniformOutput', 0);  
    hitCCDistParams = SVD.Core.Stats.hit_ev_params(profileBarcode, length(pxBarcode), hits, randBarcodeFunction);
    
    CCs = SVD.Core.Stats.res_ccs( profileBarcode, pxBarcode, hits );
    pVals = cellfun(@SVD.Core.Stats.p_val_from_dist, CCs, hitCCDistParams);
end

