function [ pVal ] = hit_pval( hitCC, nullModelCCs, nullModelCCsMax, effectiveLength )
%HIT_PVAL Returns p-value of a hit based on the hit CC and null model CCs
%   Uses CombAuc EVD functions

    import CA.CombAuc.Core.Comparison.generate_evd_par;
    import CA.CombAuc.Core.Comparison.compute_p_value;
    
    [~,rSq,evdPar] = generate_evd_par( nullModelCCsMax, nullModelCCs, effectiveLength, 'exact2');
    if rSq > 0.8
        pVal = compute_p_value(hitCC, evdPar, effectiveLength, 'functional' );
    else
        warning(['EVD doesn''t fit CC distribution well (rSq = ' 
            num2str(rSq) '. Using sampling based p-value']);
        pVal = (1 + sum(nullModelCCs > hitCC))/(1 + length(nullModelCCs));
    end       
end

