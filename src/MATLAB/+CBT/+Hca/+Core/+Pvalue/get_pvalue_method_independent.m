function [pVal] = get_pvalue_method_independent(coefs, lengths, lenLong, filtPar, stretchFactors, nI )
    % Method IN for computing p-values. Assumes independence and then 
    % corrects for this assumption
    
    % input hcaSessionStruct, sets
    % output hcaSessionStruct

    disp('Starting computing exp to theory p-values (method 1)...')
    disp('This method provides a p-value estimate...')
    disp('by first fitting a Gaussian distribution...')
    disp('and finding a correction term...')

    
    % keep the same stretch factors.
    %stretchFactors = sets.barcodeConsensusSettings.stretchFactors;
    
    % number of fragments, < lenTheory
    %numI = sets.numI;
    

    % number of runs for more accurate statistics
   % nI = 1000;
                
    % number of tries, since the p-value here is probabilistic
    %numT = sets.numT;
    
    % filter parameter
   % filtPar = sets.filtPar;
    
       
    % if the barcodes were not pre-stretched, it means that we need to
    % consider each on of them separately
    %lengths = [hcaSessionStruct.lengths mean(hcaSessionStruct.lengths)];
 
    % p-value settings input
    %sets.askForPvalueSettings = 1;
    % don't hardcode this
%     if sets.askForPvalueSettings == 1
%         sets.contigSettings.numRandBarcodes = 1;
%         sets.pvaluethresh = 0.01;
%     end

    import CA.CombAuc.Core.Comparison.generate_evd_par;
    %import CBT.Hca.Core.Pvalue.evd_params;
    import CBT.Hca.Core.Pvalue.evd_params_1;

    % theory / note that would have to tread this differently for bacteria
    
    pValueMatrix = ones(1,length(lengths));
    pV = ones(1,length(lengths));

    rSquaredExact = ones(1,length(lengths));
    evdPar =  cell(1,length(lengths));
	evT  =  cell(1,length(lengths));
    ccMax  =  cell(1,length(lengths));
    xzeros  =  cell(1,length(lengths));

%     % then each barcode gets a separate p-value perhaps?
%     for kk=1:length(hcaSessionStruct.theoryGen.theoryBarcodes)
%         disp(strcat(['Computing p-values for theory nr. ',num2str(kk) ' out of ' num2str(length(hcaSessionStruct.theoryGen.theoryBarcodes)) ]))
%         tic

        % we'll compute p-values for these coefficients
  %  coefs = cell2mat(cellfun(@(x) x.maxcoef(1),hcaSessionStruct.comparedStructure{kk},'UniformOutput',0));

%     longTheory = hcaSessionStruct.theoryGen.theoryBarcodes{kk};
%     lenLong = length(longTheory(:)); 

    % number of independent fits assuming they are all independent
    tLen = lenLong*2*length(stretchFactors);
    % one over number of fits
    b = 1/tLen;
    
    % we run through the coefficients. It's assumed that each barcode is of
    % different length
    for j=1:length(coefs)
            disp(strcat(['Computing p-values for bar. nr. ',num2str(j) ' out of ' num2str(length(coefs)) ]))

            lenC = lengths(j);

            import CBT.Hca.Core.Pvalue.get_evd_params_1;
            [evdPar{j}, rSquaredExact(j),mult, x0, par1, par2, evT{j},tLen, rST, ccMax, xzeros] = get_evd_params_1(lenC,lenLong, filtPar, stretchFactors,nI, b);

            % function for computing the p-value
            pV = @(x)  tLen*(1-normcdf(x,par1, par2));


            if coefs(j) < x0/mult
                 pValueMatrix(j) = 1;
            else
                 pValueMatrix(j) = pV(coefs(j)*mult);
            end
    end
        
    pVal.evdPar = evdPar;
        pVal.evd = evT;

    pVal.pValueMatrix = pValueMatrix;
    pVal.rsq = rSquaredExact;
    pVal.mult = mult;
    pVal.ccMax = ccMax;
    pVal.xzeros = xzeros;

    disp('Ended computing exp to theory p-values (method 1)')
    

end

