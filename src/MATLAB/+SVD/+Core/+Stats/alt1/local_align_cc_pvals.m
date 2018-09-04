function [ pVals, CCs ] = local_align_cc_pvals( queryBarcode, targetBarcode, hits, randBarcodeFunction, numRand)
%LOCAL_ALIGN_CC_PVALS Summary of this function goes here
%   Detailed explanation goes here

    import SVD.Core.Stats.hit_rand_xcorrs
    import SVD.Core.Stats.hit_pval
    
    if nargin < 5
        numRand = 1000;
    end
    
    targetLen = length(targetBarcode);
    effectiveLength = floor(targetLen/5);
    pVals = ones(1, size(hits, 1));
    CCs = zeros(1, size(hits, 1));
    
    for i = 1:length(pVals)
        if hits(i, 2) - hits(i, 1) < 2
            continue;
        end
        inc = 1;
        if hits(i, 3) > hits(i, 4)
            inc = -1;
        end
        
        [nullModelCCs, nullModelCCsMax] = hit_rand_xcorrs(queryBarcode(hits(i, 3):inc:hits(i, 4)), targetLen, randBarcodeFunction, numRand);
        hitCC = corrcoef(queryBarcode(hits(i, 3):inc:hits(i, 4)), targetBarcode(hits(i, 1):hits(i, 2)));
        CCs(i) = hitCC(2);
        pVals(i) = hit_pval(CCs(i), nullModelCCs, nullModelCCsMax, effectiveLength);
    end

end

