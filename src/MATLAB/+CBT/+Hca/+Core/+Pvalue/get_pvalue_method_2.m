function [hcaSessionStruct] = get_pvalue_method_2(hcaSessionStruct, sets )
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
    
    % then each barcode gets a separate p-value perhaps?
    for kk=1:length(hcaSessionStruct.theoryGen.theoryBarcodes)
        disp(strcat(['Computing p-values for theory nr. ',num2str(kk) ' out of ' num2str(length(hcaSessionStruct.theoryGen.theoryBarcodes)) ]))

        % we'll compute p-values for these coefficients
        coefs = cell2mat(cellfun(@(x) x.maxcoef(1),hcaSessionStruct.comparedStructure{kk},'UniformOutput',0));
    
        longTheory = hcaSessionStruct.theoryGen.theoryBarcodes{kk};
        lenLong = length(longTheory(:)); 
        tLen = lenLong*2*length(stretchFactors);
        for j=1:length(coefs)
                tic
                disp(strcat(['Computing p-values for bar. nr. ',num2str(j) ' out of ' num2str(length(coefs)) ]))

                stD = zeros(1,nI);
                ccMax = zeros(1,nI);
                rST = zeros(1,nI);
                evT = cell(1,nI);

                for i=1:nI
                    import CBT.Hca.Core.Pvalue.evd_params_1;
                    [evT{i}, rST(i),xzeros, cc] = evd_params_1(lengths(j), lenLong, filtPar, stretchFactors);
                    % how many comparisons there are in total that we sampled from
                    tLen = lenLong*2*length(stretchFactors);
                    b = 1/tLen;
                    ccMax = max(cc(:));
                    stD(i) = xzeros/ccMax;
                end
                % compute means and stds for the fit
                mu = cellfun(@(x) x.mu, evT);
                st =  cellfun(@(x) x.sigma, evT);
                
                % compute the multiplication parameter
                mult = mean(stD);
                
                % find a value for which the p-value can be set to 1
                fun = @(x) 1-normcdf(x,mean(mu), mean(st)) - b;
                x0 = fzero(fun,max(ccMax));

                % estimated distribution parameters
                par1 = mean(mu);
                par2 = mean(st);
                evdPar{kk,j} = [par1 par2];
                rSquaredExact(kk,j) = mean(rST);
                
                
                % function for computing the p-value
                pV = @(x)  tLen*(1-normcdf(x,par1, par2));

                
                if coefs(j) < x0/mult
                     pValueMatrix(kk, j) = 1;
                else
                     pValueMatrix(kk, j) = pV(coefs(j)*mult);
                end
        end
    end
        
    hcaSessionStruct.pValueResultsOneBarcode.evdPar = evT;
    hcaSessionStruct.pValueResultsOneBarcode.pValueMatrix = pValueMatrix;
    hcaSessionStruct.pValueResultsOneBarcode.rsq = rSquaredExact;
       
    disp('Ended computing exp to theory p-values (method 1)')
    

end

