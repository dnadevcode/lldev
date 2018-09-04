function [hcaSessionStruct] = get_theory_to_exp_p_values_one_barcode(hcaSessionStruct, sets )
    % get_theory_to_exp_p_values_one_barcode
    
    % input hcaSessionStruct, sets
    % output hcaSessionStruct


  disp('Starting computing exp to theory p-values (order statistics)...')
    tic

    % barcodeGenSettings = hcaSessionStruct.theoryGen.sets;
  %  import CA.CombAuc.Core.Zeromodel.generate_random_sequences;
    %import CA.CombAuc.Core.Comparison.compute_correlation;
    import CA.CombAuc.Core.Comparison.generate_evd_par;
   % import CA.CombAuc.Core.Comparison.cc_fft;

    % double check if this is the one needed
    if  sets.skipNullModelChoice == 0
        sets.nullModelPath = uigetdir(pwd,'Select folder with the pre-computed null model');
        addpath(genpath( sets.nullModelPath));    
    end
         
    % meanFFT, computed at the bp level
    meanFFTest = load(strcat([sets.nullModelPath '/meanFFT.mat']));
    meanFFTest = meanFFTest.meanFFTEst;   
    
    % todo: minimise the number of these parameters that we compute from known
    % data, a little messy now
    meanBpExt_nm =sets.barcodeGenSettings.meanBpExt_nm; % from theory lengths
    psfSigmaWidth_bps = sets.barcodeConsensusSettings.psfSigmaWidth_nm/meanBpExt_nm;
    sets.untrustedBp = round(sets.barcodeConsensusSettings.deltaCut*psfSigmaWidth_bps);
    pxPerBp = meanBpExt_nm/sets.barcodeConsensusSettings.prestretchPixelWidth_nm;
    bpPerPx = sets.barcodeConsensusSettings.prestretchPixelWidth_nm/meanBpExt_nm;

    % reference (consensus) barcode
    refBarcode= hcaSessionStruct.theoryGen.theoryBarcodes{1};
    refBitmask= hcaSessionStruct.theoryGen.bitmask{1};

    % p-value settings input
    sets.askForPvalueSettings = 1;
    % don't hardcode this
    if sets.askForPvalueSettings == 1
        sets.contigSettings.numRandBarcodes = 1;
        sets.pvaluethresh = 0.01;
    end
    
    % keep the same stretch factors.
    stretchFactors = sets.barcodeConsensusSettings.stretchFactors;
    coefs = cell2mat(cellfun(@(x) x.maxcoef(1),hcaSessionStruct.comparisonStructure,'UniformOutput',0));
    
    pValueMatrix= ones(1,length(coefs));
    pValueMatrixFiltered = ones(1,length(coefs));
    rSquaredExact = ones(1,length(coefs));
    if sets.prestretchMethod == 0

        % if the barcodes were not pre-stretched, it means that we need to
        % consider each on of them separately
        lengths = [hcaSessionStruct.lengths mean(hcaSessionStruct.lengths)];
        for ii=1:length(coefs)
             disp(strcat(['Computing p-values for bar. nr. ',num2str(ii) ' out of ' num2str(length(lengths)) ]))
            % generate one short barcode
            import CA.CombAuc.Core.Zeromodel.generate_random_sequences;
            [ randomSequences ] = generate_random_sequences(2*round(lengths(ii)*bpPerPx-2*sets.untrustedBp),sets.contigSettings.numRandBarcodes,meanFFTest,psfSigmaWidth_bps ,'phase',pxPerBp);

            xx =[];
            for i=1:length(randomSequences)
                randomSeq = randomSequences{i}(1:round(length(randomSequences{i})/2));
               % randomBit = ones(1,length(randomSeq));
                for j=1:length(stretchFactors)
                    barC = interp1(randomSeq, linspace(1,length(randomSeq),length(randomSeq)*stretchFactors(j)));
                    [xcorrs,~,~] =  CA.CombAuc.Core.Comparison.get_cc_fft(barC,refBarcode,ones(1,length(barC)),refBitmask);
                    xx = [xx xcorrs];
                end 
            end
            
            
            evdPar = CA.CombAuc.Core.Comparison.compute_distribution_parameters(xx(:),'exactCC',length(randomSeq)/5);
            rSquaredExact(ii) = CA.CombAuc.Core.Comparison.compute_r_squared(xx(:), evdPar, 'cc' );
            if length(randomSeq)==evdPar
               disp('Warning, p-value method did not converge'); 
            end

            % what should we multiply this with, what is the best value for
            % multFactor. Here we multiply by total number of fitting
            % attempts - this is how many fitting attempts will be in the
            % real comparison, and we want only a number i.e. 0.01 of them
            % would be on the rhs
            multFactor = length(xx);
            pValueMatrix(ii) = min(1,multFactor*CA.CombAuc.Core.Comparison.compute_p_value(coefs(ii),evdPar,'cc'));

            
            if sets.filterSettings.filter==1
                coefs2 = cell2mat(cellfun(@(x) x.maxcoef(1),hcaSessionStruct.comparisonStructureFiltered,'UniformOutput',0));
                pValueMatrixFiltered(ii) =  min(1,length(xx)*CA.CombAuc.Core.Comparison.compute_p_value(coefs2(ii),evdPar,'cc')); 
                hcaSessionStruct.pValueResultsOneBarcode.pValueMatrixFiltered = pValueMatrix;     
            end
            
        end
      
    else
        % if everything was stretched to the same length,
        
        % generate one short barcode
        import CA.CombAuc.Core.Zeromodel.generate_random_sequences;
        [ randomSequences ] = generate_random_sequences(2*round(mean(hcaSessionStruct.lengths)*bpPerPx-2*sets.untrustedBp),sets.contigSettings.numRandBarcodes,meanFFTest,psfSigmaWidth_bps ,'phase',pxPerBp);



        xx =[];
        for i=1:length(randomSequences)
            randomSeq = randomSequences{i}(1:round(length(randomSequences{i})/2));
           % randomBit = ones(1,length(randomSeq));
            for j=1:length(stretchFactors)
                barC = interp1(randomSeq, linspace(1,length(randomSeq),length(randomSeq)*stretchFactors(j)));
                [xcorrs,~,~] =  CA.CombAuc.Core.Comparison.get_cc_fft(barC,refBarcode,ones(1,length(barC)),refBitmask);
                xx = [xx xcorrs];
            end 
        end
      %  sortedData =sort(xx(:));

        evdPar = CA.CombAuc.Core.Comparison.compute_distribution_parameters(xx(:),'exactCC',length(randomSeq)/5);
        rSquaredExact = CA.CombAuc.Core.Comparison.compute_r_squared(xx(:), evdPar, 'cc' );
        if length(randomSeq)==evdPar
           disp('Warning, p-value method did not converge'); 
        end

        coefs = cell2mat(cellfun(@(x) x.maxcoef(1),hcaSessionStruct.comparisonStructure,'UniformOutput',0));

        pValueMatrix = min(1,length(xx)*CA.CombAuc.Core.Comparison.compute_p_value(coefs,evdPar,'cc'));
    %     
    %     f = @(x) CA.CombAuc.Core.Comparison.compute_p_value(x,evdPar,'cc')-1*sets.pvaluethresh/length(xx);
    %     threshValue = fzero(f,max(xx(:)));
        %	[ = CA.CombAuc.Core.Comparison.compute_p_value(hcaSessionStruct.comparisonStructure{ii}.maxcoef,evdPar,'exact'); 


    % 
    %     pValueMatrix = CA.CombAuc.Core.Comparison.compute_p_value(coefs,evdPar,'exact'); 
    %     
%         hcaSessionStruct.pValueResultsOneBarcode.evdPar = evdPar;
%         hcaSessionStruct.pValueResultsOneBarcode.pValueMatrix = pValueMatrix;
%         hcaSessionStruct.pValueResultsOneBarcode.rsq = rSquaredExact;

        if sets.filterSettings.filter==1
            coefs = cell2mat(cellfun(@(x) x.maxcoef(1),hcaSessionStruct.comparisonStructureFiltered,'UniformOutput',0));
            pValueMatrixFiltered =  min(1,length(xx)*CA.CombAuc.Core.Comparison.compute_p_value(coefs,evdPar,'cc')); 
          %  hcaSessionStruct.pValueResultsOneBarcode.pValueMatrixFiltered = pValueMatrixFiltered;     
        end


    end
    hcaSessionStruct.pValueResultsOneBarcode.evdPar = evdPar;
    hcaSessionStruct.pValueResultsOneBarcode.pValueMatrix = pValueMatrix;
    hcaSessionStruct.pValueResultsOneBarcode.pValueMatrixFiltered = pValueMatrixFiltered;
    hcaSessionStruct.pValueResultsOneBarcode.rsq = rSquaredExact;

        
    toc        
    disp('Ended computing exp to theory p-values (order statistics)...')
    

    
%     rawBarcodes = hcaSessionStruct.rawBarcodes;
%     rawBitmasks = hcaSessionStruct.rawBitmasks;
%     if sets.barcodeConsensusSettings.aborted==0
%         rawBarcodes = [rawBarcodes; hcaSessionStruct.consensusStruct.barcode];
%         rawBitmasks = [rawBitmasks hcaSessionStruct.consensusStruct.bitmask];
%     end
%             
%     %%%%%%%%%%%%%%%%%   
%     % unfiltered comparison
%     import CBT.Hca.UI.Helper.on_compare_theory_to_exp
%     hcaSessionStruct.comparisonStructure = on_compare_theory_to_exp(rawBarcodes,rawBitmasks, hcaSessionStruct.theoryGen.theoryBarcodes{1},hcaSessionStruct.theoryGen.bitmask{1},sets);
% 
%     timePassed = toc;
%     disp(strcat(['Experiments were compared to theory in ' num2str(timePassed) ' seconds']));
% 
%     
%     % filtered comparison
%     if sets.filterSettings.filter==1
% 
%         rawBarcodes = hcaSessionStruct.rawBarcodesFiltered;
%         rawBitmasks = hcaSessionStruct.rawBitmasksFiltered;
%         if sets.barcodeConsensusSettings.aborted==0
%             rawBarcodes = [rawBarcodes; hcaSessionStruct.consensusStructFiltered.barcode];
%             rawBitmasks = [rawBitmasks hcaSessionStruct.consensusStructFiltered.bitmask];
%         end
%         disp('Starting comparing filtered exp to theory...')
%         tic
%         if sets.filterSettings.filterMethod == 0 
%             hcaSessionStruct.comparisonStructureFiltered = on_compare_theory_to_exp(rawBarcodes,rawBitmasks, hcaSessionStruct.theoryGen.theoryBarcodes{1},hcaSessionStruct.theoryGen.bitmask{1},sets,1);   
%         else  
%             hcaSessionStruct.comparisonStructureFiltered = on_compare_theory_to_exp(rawBarcodes,rawBitmasks, hcaSessionStruct.theoryGen.theoryBarcodes{1},hcaSessionStruct.theoryGen.bitmask{1},sets);   
%         end
%          
%         timePassed = toc;
%         disp(strcat(['Filtered experiments were compared to theory in ' num2str(timePassed) ' seconds']));
%     end
%     
end

