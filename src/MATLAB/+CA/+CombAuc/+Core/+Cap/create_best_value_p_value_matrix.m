function [ pVal, pValBi] = create_best_value_p_value_matrix(pValMat, m, n)
% best value p val matrix

    pVal = ones(n,m);
    
    pVal1 = pValMat(:,1:m);
    pVal2 = pValMat(:,m+1:end);
    pValBi = sparse(pVal1 < pVal2);
    pVal(pVal1 < pVal2) = pVal1(pVal1 < pVal2);
    pVal(pVal2 < pVal1) = min(pVal(pVal2 < pVal1),pVal2(pVal2 < pVal1));

    %pVal = sparse(pVal);
    %sum(sum(pVal < pValueThresh))

end

