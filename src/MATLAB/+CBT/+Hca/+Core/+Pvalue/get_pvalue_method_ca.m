function [pVal] = get_pvalue_method_ca(vals, lengths, longBar, filtPar, stretchFactors, nI )
    % Method A for computing p-values.
    
    % input hcaSessionStruct, sets
    % output hcaSessionStruct

    disp('Starting computing exp to theory p-values (method same as contig assembly)...')
    disp('This method provides a p-value estimate...')
    disp('by first fitting a Gaussian distribution...')
    disp('and finding a correction term...')

   lenLong = length(longBar(:));
    % keep the same stretch factors.
    %stretchFactors = sets.barcodeConsensusSettings.stretchFactors;
    
    % number of fragments, < lenTheory
    %numI = sets.numI;
    

    % number of runs for more accurate statistics
    %nI = 1000;
                
    % number of tries, since the p-value here is probabilistic
    %numT = sets.numT;
    
    % filter parameter
    %filtPar = sets.filtPar;
    
       
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
    import CBT.Hca.Core.Pvalue.evd_params_ca;

    % theory / note that would have to tread this differently for bacteria
    
    pValueMatrix = ones(1,length(lengths));
    rSquaredExact = ones(1,length(lengths));
    evdPar =  cell(1,length(lengths));
    ccM =  cell(1,length(lengths));

    %evT = cell(1,length(hcaSessionStruct.theoryGen.theoryBarcodes));
    % then each barcode gets a separate p-value perhaps?
    for kk=1:length(lengths)
        disp(strcat(['Computing p-values for exp nr. ',num2str(kk) ' out of ' num2str(length(lengths)) ]))
        %tic

        % we'll compute p-values for these coefficients
       % coefs = cell2mat(cellfun(@(x) x.maxcoef(1),hcaSessionStruct.comparedStructure{kk},'UniformOutput',0));
    
        %longTheory = hcaSessionStruct.theoryGen.theoryBarcodes{kk};
         
        %tLen = lenLong*2*length(stretchFactors);
        %b = 1/tLen;

        %disp(strcat(['Computing sample cc-values for bar. nr. ',num2str(j) ' out of ' num2str(nI) ]))

        lenC = lengths(kk);

        import CBT.Hca.Core.Pvalue.get_evd_params_ca;
        [evdPar{kk}, rSquaredExact(kk), ccM{kk}] = get_evd_params_ca(lenC,longBar, filtPar, stretchFactors,nI);

%         % function for computing the p-value
%         pV = @(x)  tLen*(1-normcdf(x,par1, par2));


%         if coefs(j) < x0/mult
%              pValueMatrix(kk, j) = 1;
%         else
        import CA.CombAuc.Core.Comparison.compute_p_value;
        pValueMatrix(kk) = compute_p_value(vals(kk),evdPar{kk},'functional');
       %pValueMatrix(kk) = pV(coefs(j)*mult);
       % end
        %toc;
    end
        
    pVal.evdPar = evdPar;
    pVal.pValueMatrix = pValueMatrix;
    pVal.rsq = rSquaredExact;
    pVal.ccM = ccM;
    disp('Ended computing exp to theory p-values (method 1)')
    

end

