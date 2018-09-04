function [caSessionStruct] = compare_to_theory_ui(caSessionStruct, sets)
    % compare_to_theory_ui
    
    if nargin < 1
        caSessionStruct = [];
    end
    
    % TEMPORARY. change this to what is usual session file imported
    % Can also iterate over many consensuses..
    refBarcode = caSessionStruct.consensus{1}.barcode;
    %refBitmask = ones(1,length(refBarcode));
    refBitmask = caSessionStruct.consensus{1}.bitmask;
    
   % contigItems.barcode = caSessionStruct.theoryCurveUnscaled_pxRes;
   contigItems.barcode = caSessionStruct.theorySeq;
    contigItems.isRemoved = ones(1,length(contigItems.barcode));
     contigItems.isReversed = zeros(1,length(contigItems.barcode));
     contigItems.name = cell(1,length(contigItems.barcode));
     contigItems.BelongsToSeq =  zeros(1,length(contigItems.barcode));
   % contigBitmasks = caSessionStruct.bitmasks;
   
    % load settings, should be something like comparisonSettings, and have
    % to save them to the structure
    import CA.CombAuc.Core.Settings.settings;
    settings = settings(); % 
    
    % then the rest of the code should be loadable from a session file.
    
% 	assignin('base','refBarcode',refBarcode)
%     assignin('base','contigItems',contigItems)

      % cc vals
    ccValueMatrix = zeros(length(contigItems.barcode),2*length(refBarcode));
    pValueMatrix = ones(length(contigItems.barcode),2*length(refBarcode));
    
    % zero model pre gen
   % load('meanFFT_140116.mat');
   
    % Make the method to pregenerate this more accessible!
    % Also don't forget the random barcodes based on autocorrelation
    % method!
    
%     m = load('meanF.mat');
%     meanFFTest = interp1(m.meanFFT,linspace(1,length(m.meanFFT),m.len));
    
    load 121216.mat;

    
    import CA.CombAuc.Core.Zeromodel.generate_random_sequences;
    import CA.CombAuc.Core.Comparison.compute_correlation;
    import CA.CombAuc.Core.Comparison.generate_evd_par;
    import CA.CombAuc.Core.Comparison.cc_fft;
    import CA.CombAuc.Core.Comparison.compute_p_value;

    psfSigmaWidth_bps = caSessionStruct.barcodeGenSettings.psfSigmaWidth_nm / caSessionStruct.barcodeGenSettings.meanBpExt_nm;
    meanBpExt_pixels = caSessionStruct.barcodeGenSettings.meanBpExt_nm / caSessionStruct.barcodeGenSettings.prestretchPixelWidth_nm;

    for contigNum=1:length(contigItems.barcode)
        contigNum
        % if there is only one pixel, not possible to do statistics
        if length(contigItems.barcode{contigNum})<3
            
        else
            [ randomSequences ] = generate_random_sequences(2*length(contigItems.barcode{contigNum}),1000,meanFFTest, psfSigmaWidth_bps*meanBpExt_pixels,'phase');
            for i=1:length(randomSequences)
                randomSequences{i} = zscore(randomSequences{i}(1:end/2));
            end
       
            % evd pars
            [ccMax,~] = compute_correlation(length(contigItems.barcode{contigNum}), length(refBarcode),  'shortPrec',  psfSigmaWidth_bps*meanBpExt_pixels,randomSequences,refBarcode);
            
            if mean(ccMax)+3*std(ccMax) < 1 % otherwise does not make sense to have p-values, too small contigs
                [~,rSq,evdPar] = generate_evd_par( ccMax,[],length(contigItems.barcode{contigNum})/5, 'exact2' );
               % rSq
                evdPar
                [cc1,cc2] = cc_fft(zscore(contigItems.barcode{contigNum}),refBarcode);

                ccValueMatrix(contigNum,:) = [cc1 cc2];
                pValueMatrix(contigNum,:) = compute_p_value(ccValueMatrix(contigNum,:),evdPar,'exact'); 
            else
                [cc1,cc2] = cc_fft(zscore(contigItems.barcode{contigNum}),refBarcode);

                ccValueMatrix(contigNum,:) = [cc1 cc2];
            end
        end
       % end
    end
    
%       for contigNum=1:length(contigItems.barcode)
%         contigNum
%         % if there is only one pixel, not possible to do statistics
%         if length(contigItems.barcode{contigNum})<3
%              pValueMatrix(contigNum,:) = ones(1,length(pValueMatrix(contigNum,:)));
%         end
%       end
    
    %figure,plot(ccMatrix(1,:))
   % ppMatrix(1,1:10)

  % figure, plot(ppMatrix(2,:)) 
   % ppMatrix(2,:)
	%ppMatNew = [];
    %contigLen = cellfun(@length,contigItems{i})-1;

    contigLengths =[];

 %   contigb = {};

    for contigNum = 1:size(pValueMatrix,1)
       % if contigItems{contigNum}.isTooShort ~=1
            contigLengths = [contigLengths length(contigItems.barcode{contigNum})-1];
%         else
%             contigLengths = [contigLengths 0];
%         end

           % ppMatNew = [ppMatNew; ppMatrix(i,:)];
         %  probN = [probN probNums(i)];
    end
  
   % m = size(ppMat,2)/2;
   % n = size(ppMat,1);

    % redefine that pVal would be only those values < 1 ? 
    import CA.CombAuc.Core.Cap.create_best_value_p_value_matrix;
    [ pVal, pValBi] = create_best_value_p_value_matrix(pValueMatrix, length(refBarcode),length(contigItems.barcode));

    % create a bidMat, also takes into account that the bid is for the first
    % item and not the last
    
    import CA.CombAuc.Core.Cap.convert_first_item_to_last_item;

    [bidMat, ~, contigLengths2,n, II, xInd ] = convert_first_item_to_last_item(pVal, settings.pValueThresh, contigLengths,  length(refBarcode),length(contigItems.barcode));
    
    %[bidMat, contigLengths2 ] = Cap.add_overlap( bidMat, contigLengths2, settings.allowedOverlap);

    %tic    
    import CA.CombAuc.Core.Cap.contig_placement_optimal_value;

    [optAuctionOutcome, bestValues, opIndex2] = contig_placement_optimal_value(bidMat, contigLengths2,  length(refBarcode), n);
   % toc

    if optAuctionOutcome~=0
        
        import CA.CombAuc.Core.Cap.contig_placement_optimal_bid;
        [optBid] = contig_placement_optimal_bid( bestValues, opIndex2, bidMat, contigLengths2, n,  length(refBarcode));
        optimalBid = sortrows(optBid,3);
        
       % import Cap.return_to_overlap;
       % optimalBid = return_to_overlap(optimalBid, length(refBarcode), settings.allowedOverlap );

        uniqueItems = unique(II);
        uniqueFormer = unique(xInd);
        for i=1:size(optimalBid,1)
           optimalBid(i,1) = uniqueFormer(find(uniqueItems==optimalBid(i,1)));
           contigItems.PredictedPlacePxStart(optimalBid(i,1)) = optimalBid(i,2);
           contigItems.PredictedPlacePxEnd(optimalBid(i,1)) = optimalBid(i,3);
           contigItems.isRemoved(optimalBid(i,1)) = 0;
     
           contigItems.isReversed(optimalBid(i,1)) = full(pValBi(optimalBid(i,1),optimalBid(i,2)));
        end
              
            % 
        colors = rand(size(contigItems.barcode,2),3);
        distCol = [1 0 0; 0 0.5 0; 0 0 1];
        cInd = 1;

        import CA.CombAuc.Export.Plot.plot_contigs3;

        figure
        plot_contigs3(zscore(refBarcode),contigItems, 'Contig assembly using 220 pUUH/chromosomal DNA contigs',ccValueMatrix,pValueMatrix,colors);

       % h = plot_contigs(refBarcode,contigItems, 'Contig placement',pValueMatrix);
    end

end