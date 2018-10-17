function [evdPar, cM] = precompute_pvalue_params_method1(barLen, len1, strFac, data)
    % precompute p-value evd parameters based on method 1
    indx = round(barLen*strFac);
    [~, idx] = intersect(len1, indx);
    if length(idx) >1
        maxCCVals = max(cell2mat(data(idx)'));
    else
        maxCCVals = cell2mat(data(idx)');
    end
    import CA.CombAuc.Core.Comparison.compute_distribution_parameters;
    evdPar = compute_distribution_parameters(maxCCVals(:),'functional',barLen/5);
    
    nPt = 50;
   % h = functional_max(evdPar,maxCCVals(:),nPt);
    cM = max(maxCCVals(:));
end

