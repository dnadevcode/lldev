function [ p, cal ] = compute_p_val_score(cMaxVals, pvalData, barLen,strFac )


    p = zeros(1,length(barLen));
    cal = ones(1,length(barLen));
    for i=1:length(barLen)
        disp(strcat(['Computing p-values for barcode nr.' num2str(i)])); 
        % compute barcode lengths when stretched
        indx = round(barLen(i)*strFac);
        % intersect with corresponding values from the database
        [~, idxIntoA] = intersect(pvalData.len1, indx);
        if ~isequal(length(idxIntoA),length(indx))
            warning('Not enough data in the p-value database for this barcode');  
            p(i) = 1;
            cal(i) = 0;
        else
            % extract the cc coefficients for all the different
            % possible lengths
            maxCCVals = max(cell2mat(pvalData.data(idxIntoA))');

            import CA.CombAuc.Core.Comparison.compute_distribution_parameters;
            evdPar = compute_distribution_parameters(maxCCVals(:),'functional',barLen(i)/5);

            import CA.CombAuc.Core.Comparison.compute_p_value;
            p(i) = compute_p_value(cMaxVals(i), evdPar,'functional');
        end
    end
    
end

