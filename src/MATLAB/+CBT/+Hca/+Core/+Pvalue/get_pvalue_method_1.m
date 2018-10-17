function [pVal] = get_pvalue_method_1(hcaSessionStruct, sets )
    % Method A for computing p-values.
    
    % input hcaSessionStruct, sets
    % output hcaSessionStruct

    disp('Starting computing exp to theory p-values (method 1)...')
    disp('This method provides a p-value estimate...')
    disp('by first fitting a Gaussian distribution...')
    disp('and finding a correction term...')

    
    % keep the same stretch factors.
    stretchFactors = sets.barcodeConsensusSettings.stretchFactors;
    
    % number of fragments, < lenTheory
    %numI = sets.numI;
    

    % number of runs for more accurate statistics
    nI = 1000;
                
    % number of tries, since the p-value here is probabilistic
    %numT = sets.numT;
    
    % filter parameter
    filtPar = sets.filtPar;
    
       
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
    import CBT.Hca.Core.Pvalue.evd_params_1;

    % theory / note that would have to tread this differently for bacteria
    
    pValueMatrix = ones(length(hcaSessionStruct.theoryGen.theoryBarcodes),length(hcaSessionStruct.lengths));
    rSquaredExact = ones(length(hcaSessionStruct.theoryGen.theoryBarcodes),length(hcaSessionStruct.lengths));
    evdPar =  cell(length(hcaSessionStruct.theoryGen.theoryBarcodes),length(hcaSessionStruct.lengths));
    evT = cell(1,length(hcaSessionStruct.theoryGen.theoryBarcodes));
    % then each barcode gets a separate p-value perhaps?
    for kk=1:length(hcaSessionStruct.theoryGen.theoryBarcodes)
        disp(strcat(['Computing p-values for theory nr. ',num2str(kk) ' out of ' num2str(length(hcaSessionStruct.theoryGen.theoryBarcodes)) ]))
        tic

        % we'll compute p-values for these coefficients
        coefs = cell2mat(cellfun(@(x) x.maxcoef(1),hcaSessionStruct.comparedStructure{kk},'UniformOutput',0));
    
        longTheory = hcaSessionStruct.theoryGen.theoryBarcodes{kk};
        lenLong = length(longTheory(:)); 
        tLen = lenLong*2*length(stretchFactors);
        b = 1/tLen;

        for j=1:length(coefs)
                disp(strcat(['Computing p-values for bar. nr. ',num2str(j) ' out of ' num2str(length(coefs)) ]))
                
                lenC = lengths(j);

                import CBT.Hca.Core.Pvalue.get_evd_params_1;
                [evdPar{kk,j}, rSquaredExact(kk,j),mult, x0,par1,par2, evT{j},tLen] = get_evd_params_1(lenC,lenLong, filtPar, stretchFactors,nI, b);
                 
                % function for computing the p-value
                pV = @(x)  tLen*(1-normcdf(x,par1, par2));

                
                if coefs(j) < x0/mult
                     pValueMatrix(kk, j) = 1;
                else
                     pValueMatrix(kk, j) = pV(coefs(j)*mult);
                end
        end
        toc;
    end
        
    pVal.evdPar = evT;
    pVal.pValueMatrix = pValueMatrix;
    pVal.rsq = rSquaredExact;
       
    disp('Ended computing exp to theory p-values (method 1)')
    

end

