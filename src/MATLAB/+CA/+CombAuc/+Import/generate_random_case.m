function [true,placed,all,coverage,contigItems,ccValueMatrix,pValueMatrix] = generate_random_case( mol2, meanFFTest,sets,evdMat)
    % generate_random_case
    if nargin < 8
        show = 0;
    end
    
    if nargin < 4 
        evdMat= [];
    end

    import CA.CombAuc.Core.Comparison.gen_fake_rand
 %   sets.contigLen = contigSizeInBp;
    %settings.lengthBarcode = length(barcodePxRes);
    contigItems = gen_fake_rand(mol2, sets);
    
  %  lengthvector = cellfun(@(x) length(x.barcode),contigItems);
    lengthInBP = cellfun(@(x) length(x.bar),contigItems);

    refBarcode = mol2.correctAlignedBar;
    refBitmask = mol2.correctAlignedBit;

  %  [contigItems] = gen_fake_5(barcodeBpRes, settings,plasmid,chromosomalBpRes,len,tt);
      
    %lens = cellfun(@length, sequences);

    % improve thissss!!!!
%      import Plot.plot_contigs;
%      plot_contigs(refBarcode,contigItems, 'Contig placement');

      % cc vals
    ccValueMatrix = zeros(length(contigItems),2*length(refBarcode));
    pValueMatrix = ones(length(contigItems),2*length(refBarcode));

    ccValueMatrix = zeros(length(contigItems),2*length(refBarcode));
    pValueMatrixFitted = ones(length(contigItems),2*length(refBarcode));

    % zero model pre gen
    % load('meanFFT_140116.mat');
    %load('meanFFT.mat');
    %contigItems
    pxPerBp = sets.meanBpExt_nm/sets.barcodeConsensusSettings.prestretchPixelWidth_nm;
    %meanBpExt_pixels = sets.meanBpExt_nm / sets.barcodeConsensusSettings.prestretchPixelWidth_nm;
    psfWidth = sets.barcodeConsensusSettings.psfSigmaWidth_nm/sets.meanBpExt_nm;

    for contigNum=1:length(contigItems)
%        if  lengthInBP(contigNum)-2*sets.untrustedBp-4/pxPerBp > 0
        if  lengthInBP(contigNum)-4*sets.untrustedBp > 0 && length(contigItems{contigNum}.barcode) < length(refBarcode)
           % contigNum
            
            if ~isempty(evdMat)
                evdPar = evdMat(length(contigItems{contigNum}.barcode),:);
            else
                
           %     tic
                sets.contigSettings.numRandBarcodes = 1000;
                import CA.CombAuc.Core.Zeromodel.generate_random_sequences;
                [ randomSequences ] = generate_random_sequences(2*round((lengthInBP(contigNum)-2*sets.untrustedBp)),sets.contigSettings.numRandBarcodes,meanFFTest,psfWidth ,'phase',pxPerBp);
            %    toc
                ccMax = ones(1,sets.contigSettings.numRandBarcodes);

              %  xx =[];
                for i=1:length(randomSequences)
                    randomSequences{i} = randomSequences{i}(1:round(length(randomSequences{i})/2));
    %                 import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
    %                  [xcorrs, coverageLens, firstOffset] = get_no_crop_lin_circ_xcorrs(randomSequences{i},refBarcode,ones(1,length(randomSequences{i})),refBitmask);

                     [xcorrs,~,~] =  CA.CombAuc.Core.Comparison.get_cc_fft(randomSequences{i},refBarcode,ones(1,length(randomSequences{i})),refBitmask);

                     ccMax(i) = max(xcorrs(:));
                   % ccMax2(i) = max(xcorrs2(:));

                  %  xx = [xx;xcorrs(:)];
                end

               % ccMax(ccMax>1) = 1-1E-5;
           %    tic
                import CA.CombAuc.Core.Comparison.generate_evd_par;
                [~,rsq,evdPar] = generate_evd_par( ccMax,[],length(randomSequences{1}), 'exact2' );
           %     toc
    % 
            end
            
            %rsq
            %pvalFun = @(x) Comparison.compute_p_value(x,evdPar,'exact'); 

            pValueMatrix(contigNum,:) = Comparison.compute_p_value(ccValueMatrix(contigNum,:),evdPar,'exact'); 
                  
         %   sortedVals = sort(ccMax(:));
            
           % Comparison.compare_distribution_to_data( ccMax(:), evdPar, 'exactfull' )

   
%             currentFolder = pwd;
%             name = strcat([currentFolder '/puuhStats ' '.mat']);
%             save(name, '-v7.3', 'contigItems','contigNum');
            [xcorrs,~,~] =  CA.CombAuc.Core.Comparison.get_cc_fft(zscore(contigItems{contigNum}.barcode),refBarcode,contigItems{contigNum}.bit,refBitmask);
            
            ccValueMatrix(contigNum,:) = [xcorrs(1,:) xcorrs(2,:)];
            pValueMatrix(contigNum,:) = Comparison.compute_p_value(ccValueMatrix(contigNum,:),evdPar,'exact'); 
%             vec = ccValueMatrix(contigNum,:);
%             pValueMatrixFitted(contigNum,:) = arrayfun(@find, sortedVals>,1,'first');
        end
    end

    contigLengths =[];

    %   contigb = {};

    for i = 1:size(pValueMatrix,1)
            contigLengths = [contigLengths length(contigItems{i}.barcode)-1];
    end

    % redefine that pVal would be only those values < 1 ? 
    import Cap.create_best_value_p_value_matrix;
    [ pVal, pValBi] = create_best_value_p_value_matrix(pValueMatrix, length(refBarcode),length(contigItems));

    % create a bidMat, also takes into account that the bid is for the first
    % item and not the last
    [bidMat, ~, contigLengths2,n, II, xInd ] = Cap.convert_first_item_to_last_item(pVal, sets.contigSettings.pValueThresh, contigLengths,  length(refBarcode),length(contigItems));

    %[bidMat, contigLengths2 ] = Cap.add_overlap( bidMat, contigLengths2, settings.allowedOverlap);

    %tic
    [optAuctionOutcome, bestValues, opIndex2] = Cap.contig_placement_optimal_value(bidMat, contigLengths2,  length(refBarcode), n);
    % toc

    if optAuctionOutcome~=0
        [optBid] = Cap.contig_placement_optimal_bid( bestValues, opIndex2, bidMat, contigLengths2, n,  length(refBarcode));
        optimalBid = sortrows(optBid,3);

       % import Cap.return_to_overlap;
       % optimalBid = return_to_overlap(optimalBid, length(refBarcode), settings.allowedOverlap );

        uniqueItems = unique(II);
        uniqueFormer = unique(xInd);
        for i=1:size(optimalBid,1)
           optimalBid(i,1) = uniqueFormer(find(uniqueItems==optimalBid(i,1)));
           contigItems{optimalBid(i,1)}.PredictedPlacePxStart = optimalBid(i,2);
           contigItems{optimalBid(i,1)}.PredictedPlacePxEnd = optimalBid(i,3);
           contigItems{optimalBid(i,1)}.isRemoved = 0;
           contigItems{optimalBid(i,1)}.isReversed = full(pValBi(optimalBid(i,1),optimalBid(i,2)));
        end
        
        m = optimalBid(:,1);

        colors = rand(size(contigItems,2),3);
        distCol = [1 0 0; 0 0.5 0; 0 0 1; 0.5 0 0.5; 0 0.5 0.5];
        cInd = 1;

        for contigNum=m' % does not include flip option
                if	contigItems{contigNum}.isRemoved ~= 1;
                    colors(contigNum,:) = distCol(cInd,:);
                    cInd = cInd +1;
                end
        end
            
%         figure
%         import Plot.plot_contigs_edited;
%        plot_contigs_edited(refBarcode,contigItems, 'Contig assembly using synthetic pUUH/chromosomal DNA contigs',ccValueMatrix,pValueMatrix,colors,sets);

    end



%         m = [];
%         st =[];
%         se =[]; 
%         for i=1:length(contigItems)
%             if contigItems{i}.BelongsToSeq == 1
%                 m = [m i];
%                 st = [st contigItems{i}.corPlacePxStart];
%                 se =  [se contigItems{i}.corPlacePxEnd];
%             end
%         end
            % 


       % if show==1

          % end
       true = 0;
       placed = 0;
       all = 0;
       coverage = 0;
       for j = 1:length(contigItems)
           all = all +1;
           if contigItems{j}.isRemoved == 0
               if norm(contigItems{j}.corPlacePxStart -contigItems{j}.PredictedPlacePxStart) < 3 ||norm(contigItems{j}.corPlacePxStart -contigItems{j}.PredictedPlacePxStart-length(refBarcode)+1) < 3 && contigItems{j}.isChromosomal == 0
                   true = true+1;
                   coverage = coverage+length(contigItems{j}.bar);
               end
               placed = placed + 1;
           end
       end


end

