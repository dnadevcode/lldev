function [hcaSessionStruct] = get_pvalue(hcaSessionStruct, sets )
    % Based on ideas of R.Marie paper. But we do everything for random
    % barcodes!
    
    % input hcaSessionStruct, sets
    % output hcaSessionStruct

    disp('Starting computing exp to theory p-values (order statistics)...')
    
    
    % we'll compute p-values for these coefficients
    coefs = cell2mat(cellfun(@(x) x.maxcoef(1),hcaSessionStruct.comparisonStructure,'UniformOutput',0));
    
    % keep the same stretch factors.
    stretchFactors = sets.barcodeConsensusSettings.stretchFactors;
    
    % filter parameter
    filtPar = sets.barcodeConsensusSettings.psfSigmaWidth_nm/sets.barcodeConsensusSettings.prestretchPixelWidth_nm;
       
    
    % if the barcodes were not pre-stretched, it means that we need to
    % consider each on of them separately
    lengths = [hcaSessionStruct.lengths mean(hcaSessionStruct.lengths)];
 
    % p-value settings input
    %sets.askForPvalueSettings = 1;
    % don't hardcode this
%     if sets.askForPvalueSettings == 1
%         sets.contigSettings.numRandBarcodes = 1;
%         sets.pvaluethresh = 0.01;
%     end

    import CA.CombAuc.Core.Comparison.generate_evd_par;
    import CBT.Hca.Core.Pvalue.evd_params;
    import CBT.Hca.Core.Pvalue.evd_params2;

    % theory / note that would have to tread this differently for bacteria,
    % then each barcode gets a separate p-value perhaps?
    longTheory = cell2mat(hcaSessionStruct.theoryGen.theoryBarcodes);
    lenLong = length(longTheory(:));
   
    
    % simulated theory   
%     refBarcode = imgaussfilt(rand(1,lenT), filtPar);
%     refBitmask= ones(1,lenT);


    pValueMatrix= ones(1,length(coefs));
    rSquaredExact = ones(1,length(coefs));
    evdPar =  ones(1,length(coefs));
    if sets.prestretchMethod == 0
        for i=1:length(coefs)
            tic
            disp(strcat(['Computing p-values for bar. nr. ',num2str(i) ' out of ' num2str(length(coefs)) ]))

            % note that it might be good to compute this a few times and
            % then take the average, or to take the average+3sigma...
            
            jj = 10;
            evT = zeros(1,jj);
            rST = zeros(1,jj);
            cc = cell(1,jj);
            for j=1:jj
                j
               % [evT(j), rST(j),cc{j}] = evd_params(lengths(i), lenLong, filtPar, stretchFactors);
                [evT(j), rST(j)] = evd_params2(lengths(i), lenLong, filtPar, stretchFactors);
            end
            
            mean(evT(find(rST>0.95)))
            
            evdPar(i) = mean(evT);
            rSquaredExact(i) = mean(rST);
            % again, maybe enough to use a subsample. We find for what cc
            % p-value is less than b. It gives a much better estimate than
            % just taking max(cc(:))!
            
            b = 1/length(cc{1}(:));
            fun = @(x) CA.CombAuc.Core.Comparison.compute_p_value(x,evdPar(i),'cc') - b;

            % make sure this converges..
            x0 = fzero(fun,max(cc(:)));
            
            if coefs(i) < x0
                 pValueMatrix(i) = 1;
            else
                 pValueMatrix(i) = length(cc(:))*CA.CombAuc.Core.Comparison.compute_p_value(coefs(i),evdPar(i),'cc');
            end

            toc
        end
    else
         disp(strcat(['Computing p-values' ]))

         [evdPar{1}, rSquaredExact(1),cc] = evd_params(lengths(1), lenLong, filtPar, stretchFactors);
         b = 1/length(cc(:));
         fun = @(x) CA.CombAuc.Core.Comparison.compute_p_value(x,evdPar(i),'cc') - b;

         % make sure this converges..
         x0 = fzero(fun,max(cc(:)));
         
         for i=1:length(coefs)

            if coefs(i) < x0
                 pValueMatrix(i) = 1;
            else
                 pValueMatrix(i) = length(cc(:))*CA.CombAuc.Core.Comparison.compute_p_value(coefs(i),evdPar(1),'cc');
            end

            toc
         end      
    end
        


    hcaSessionStruct.pValueResultsOneBarcode.evdPar = evdPar;
    hcaSessionStruct.pValueResultsOneBarcode.pValueMatrix = pValueMatrix;
    %hcaSessionStruct.pValueResultsOneBarcode.pValueMatrixFiltered = pValueMatrixFiltered;
    hcaSessionStruct.pValueResultsOneBarcode.rsq = rSquaredExact;

        
            
    disp('Ended computing exp to theory p-values')
    

end

