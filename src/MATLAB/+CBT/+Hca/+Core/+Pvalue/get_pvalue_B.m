function [hcaSessionStruct] = get_pvalue_B(hcaSessionStruct, sets )
    % Method B for computing p-values.
    
    % input hcaSessionStruct, sets
    % output hcaSessionStruct

    disp('Starting computing exp to theory p-values (order statistics)...')
    
    
    % we'll compute p-values for these coefficients
    coefs = cell2mat(cellfun(@(x) x.maxcoef(1),hcaSessionStruct.comparisonStructure,'UniformOutput',0));
    
    % keep the same stretch factors.
    stretchFactors = sets.barcodeConsensusSettings.stretchFactors;
    
    % number of fragments, < lenTheory
    numI = 2000;
    
    % number of tries, since the p-value here is probabilistic
    numT = sets.contigSettings.numRandBarcodes;
    
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
    %import CBT.Hca.Core.Pvalue.evd_params;
    import CBT.Hca.Core.Pvalue.evd_params_A;

    % theory / note that would have to tread this differently for bacteria,
    % then each barcode gets a separate p-value perhaps?
    longTheory = cell2mat(hcaSessionStruct.theoryGen.theoryBarcodes);
    lenLong = length(longTheory(:)); 
    tLen = lenLong*2*length(stretchFactors);

    pValueMatrix = ones(1,length(coefs));
    rSquaredExact = ones(numT,length(coefs));
    evdPar =  cell(1,length(coefs));
    if sets.prestretchMethod == 0
        for i=1:length(coefs)
            tic
            disp(strcat(['Computing p-values for bar. nr. ',num2str(i) ' out of ' num2str(length(coefs)) ]))

            % note that it might be good to compute this a few times and
            % then take the average, or to take the average+3sigma...
            
            evT = cell(1,numT);
            rST = zeros(1,numT);
            % cc = cell(1,numT);
            xzeros = zeros(1,numT);
            for j=1:numT
                    % counts and prints the fraction of steps completed
                if j ~= 1
                    fprintf(1,'\b\b\b\b\b%1.3f', j/numT); 
                else
                    fprintf(1,'%1.3f',j/numT); 

                end
               % [evT(j), rST(j),cc{j}] = evd_params(lengths(i), lenLong, filtPar, stretchFactors);
                [evT{j}, rST(j),xzeros(j)] = evd_params_A(lengths(i), lenLong, filtPar, stretchFactors, numI);
            end
            import CA.CombAuc.Core.Comparison.compute_distribution_parameters;
            evdParams = compute_distribution_parameters(xzeros(:),'gumbel',20);
            pValueMatrix(1,i) = evcdf(coefs(i),evdParams.mu,evdParams.sigma);
            evdPar{i} = evT;
            toc
        end 
           
    else

        tic
        disp(strcat(['Computing p-values for bar. nr. ',num2str(i) ' out of ' num2str(length(coefs)) ]))
        
        
        evT = cell(1,numT);
        rST = zeros(1,numT);
        % cc = cell(1,numT);
        xzeros = zeros(1,numT);
        for j=1:numT
           % [evT(j), rST(j),cc{j}] = evd_params(lengths(i), lenLong, filtPar, stretchFactors);
            [evT{j}, rST(j),xzeros(j)] = evd_params_A(lengths(1), lenLong, filtPar, stretchFactors, numI);
            
        end
        
        import CA.CombAuc.Core.Comparison.compute_distribution_parameters;
        evdParams = compute_distribution_parameters(xzeros(:),'gumbel',20);
        for i=1:length(coefs)
            pValueMatrix(1,i) = evcdf(coefs(i),evdParams.mu,evdParams.sigma);
        end      
    end
        
    hcaSessionStruct.pValueResultsOneBarcode.evdPar = evT;
    hcaSessionStruct.pValueResultsOneBarcode.pValueMatrix = pValueMatrix;
    %hcaSessionStruct.pValueResultsOneBarcode.pValueMatrixFiltered = pValueMatrixFiltered;
    hcaSessionStruct.pValueResultsOneBarcode.rsq = rSquaredExact;
       
    disp('Ended computing exp to theory p-values')
    

end

