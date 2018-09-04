function [mleculeStruct] = compare_cat_theory(mleculeStruct,sets )
    % the main function to compare fragments of human chromosome vs. theory
    
%     
%     display('Starting comparing exp to theory...')
%     tic
%     if nargin < 3
%         cache = containers.Map();
%     end
    
    flt = sets.filterSettings.filter;
    % here we can consider also different methods of alignment, such us
    % xcorr, hmm, etc. Barcodes will be bitweighted here
   
    %figure,plot(hcaSessionStruct.barcodeGen{1}.rawBarcode)

% note: renaming is unnecessary now!
    barcode = cell(1,length(mleculeStruct.rawBarcodes));
    bitmask = cell(1,length(mleculeStruct.rawBarcodes));
%     barcodeFiltered = cell(1,length(hcaSessionStruct.rawBarcodesFiltered));
%     bitmaskFiltered = cell(1,length(hcaSessionStruct.rawBarcodesFiltered));
  
    
    for jInd = 1:length(mleculeStruct.rawBarcodes)
        barcode{jInd} = mleculeStruct.rawBarcodes{jInd};
        bitmask{jInd} = mleculeStruct.rawBitmasks{jInd};  
%         if sets.filterSettings.filter == 1
%             barcodeFiltered{jInd} = hcaSessionStruct.rawBarcodesFiltered{jInd}; % should we change bitmask as well?
%             bitmaskFiltered{jInd} = hcaSessionStruct.rawBitmasksFiltered{jInd}; % should we change bitmask as well?
%         end
    end

    % moved this to consensus wrapper!! ->
    
%      % how to choose the right consensus stuff?
%      % make sure this takes the cluster barcode with most barcodes in it..
%     if ~isempty(hcaSessionStruct.consensusStruct)
%         
%         % temporary hack to get barcode with most elements |avoids the need for 
%         % user input0. Depends on
%         % threshold selected..
%         
%         lengths = cellfun(@length,hcaSessionStruct.consensusStruct.clusterKeys);
%         [~,b] = max(lengths);
%         key = hcaSessionStruct.consensusStruct.clusterKeys{b};
%         consSt = hcaSessionStruct.consensusStruct.barcodeStructsMap(key);
%         hcaSessionStruct.names{jInd+1} = key ;
%         barExp.barcode{jInd+1} = consSt.barcode;
%         barExp.bitmask{jInd+1} = logical(consSt.indexWeights);
%         
%         if hcaSessionStruct.filterSettings.filter == 1
%             lengths = cellfun(@length,hcaSessionStruct.consensusStructFiltered.clusterKeys);
%             [~,b] = max(lengths);
%             key = hcaSessionStruct.consensusStructFiltered.clusterKeys{b};
%             consSt = hcaSessionStruct.consensusStructFiltered.barcodeStructsMap(key);
%             hcaSessionStruct.names{jInd+2} = key ;
%             barExp.barcode{jInd+2} = consSt.barcode;
%             barExp.bitmask{jInd+2} = logical(consSt.indexWeights);
%         end
%             % make this work only for one barcode
% %          import CBT.Consensus.Helper.make_cluster_structs;
% %         [clusterKeys, clusterConsensusDataStructs] = make_cluster_structs(hcaSessionStruct.consensusStruct);
% %         for j=jInd+1:jInd+length(clusterConsensusDataStructs)
% %             barExp.barcode{j} = clusterConsensusDataStructs{j-jInd}.barcode;
% %             barExp.bitmask{j} = clusterConsensusDataStructs{j-jInd}.bitmask;
% %             hcaSessionStruct.names{j} = clusterConsensusDataStructs{j-jInd}.clusterKey; % change name to key
% %         end
%     end
    
    theorBar = mleculeStruct.theorySeq;
    theorBit = mleculeStruct.bitmask;
    
    comparisonStructure = cell(length(barcode),1);
    comparisonStructure2 = cell(length(barcode),1);
    
    stretchedBar2 =  cell(length(barcode),1);
    bestBarStretch = zeros(1,length(barcode));
    bestBarStretch2 = zeros(1,length(barcode));
    bestStretchedBitmask = cell(length(barcode),1);
    bestStretchedBitmask2 =  cell(length(barcode),1);
    bestStretchedBar = cell(length(barcode),1);
    bestXcorr = zeros(1,length(barcode));
    bestXcorr2 = zeros(1,length(barcode));

    % stretch factor set up
%     skipStretch = 1;
%     stretchFactors = [1];
% % 
%     if skipStretch~=0
%         import CBT.ExpComparison.Import.prompt_stretch_factors;
%         stretchFactors = prompt_stretch_factors();
%     end
%     
%     % temp str factors.
%     stretchFactors =[ 0.9700    0.9800    0.9900    1.0000    1.0100    1.0200    1.0300];
	stretchFactors = sets.barcodeConsensusSettings.stretchFactors;

    for i=1:length(barcode)
         if ~isempty(barcode{i})
             import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;

             if sets.barcodeConsensusSettings.skipStretch == 0
                 [xcorrs, coverageLens, firstOffset] = get_no_crop_lin_circ_xcorrs(barcode{i}, theorBar, bitmask{i},theorBit);
                 comparisonStructure{i} = xcorrs;
                 [xcorrs, coverageLens, firstOffset] = get_no_crop_lin_circ_xcorrs(barcode{i}, theorBar, barcode{i},theorBit);
                 comparisonStructure2{i} = xcorrs;
             else
    %             if flt == 1
                xcorrs2 = cell(1,length(stretchFactors));
                xcorrMax2 = zeros(1,length(stretchFactors));
    %             end
                xcorrs = cell(1,length(stretchFactors));
                xcorrMax = zeros(1,length(stretchFactors));

               % stretchedBar = cell(1,length(stretchFactors));
               % stretchedBitmask = cell(1,length(stretchFactors));
               barTested = barcode{i};
               barBitmask = bitmask{i};
    %            if flt == 1
    %                barFilt = barcodeFiltered{i};
    %                bitFilt = bitmaskFiltered{i};
    %            end
               filterMethod = sets.filterSettings.filterMethod;
               filterSize = sets.barcodeConsensusSettings.psfSigmaWidth_nm/sets.barcodeConsensusSettings.prestretchPixelWidth_nm;
               filterSize = 1.05;

               parfor j=1:length(stretchFactors)
                    % here interpolate both barcode and bitmask.
                    barC = interp1(barTested, linspace(1,length(barTested),length(barTested)*stretchFactors(j)));
                   % stretchedBar{j} = barC;
                    barB = barBitmask(round(linspace(1,length(barBitmask),length(barBitmask)*stretchFactors(j))));
                   % stretchedBitmask{j} = barB;
                    if length(barC) > length(theorBar)
                        [xcorrs{j}, ~, ~] = get_no_crop_lin_circ_xcorrs(theorBar,barC, theorBit,barB);
                    else
                        [xcorrs{j}, ~, ~] = get_no_crop_lin_circ_xcorrs(barC, theorBar, barB,theorBit);
                    end

                    xcorrMax(j) = max(xcorrs{j}(:));

                   % filtering
                    barC = imgaussfilt(barC, filterSize); 

                    if length(barC) > length(theorBar)
                        [xcorrs2{j}, ~, ~] = get_no_crop_lin_circ_xcorrs(theorBar,barC, theorBit,barB);
                    else
                        [xcorrs2{j}, ~, ~] = get_no_crop_lin_circ_xcorrs(barC, theorBar, barB,theorBit);
                    end
                    xcorrMax2(j) = max(xcorrs2{j}(:));

                    %barB = bitFilt(round(linspace(1,length(barB),length(barB)*stretchFactors(j))));

    %                 % simplify this later by factorizing/vectorizing..
    %                 if flt == 1
    %                     barC = interp1(barFilt, linspace(1,length(barFilt),length(barFilt)*stretchFactors(j)));
    %                    % stretchedBarFiltered{j} = barC;
    %                     barB = bitFilt(round(linspace(1,length(bitFilt),length(bitFilt)*stretchFactors(j))));
    %                    

    %                     % stretchedBitmaskFiltered{j} = barB;
    %                     %barB = barExp.bitmask{i}(round(linspace(1,length(barExp.barcode{i}),length(barExp.barcode{i})*stretchFactors(j))));
    %                     %stretchedBitmask{j} = barB;

    %                 end
                end

                [a,b] = max(xcorrMax);
                comparisonStructure{i} = xcorrs{b};

                bestBarStretch(i) = stretchFactors(b);
                bestStretchedBar{i} = interp1(barcode{i}, linspace(1,length(barcode{i}),length(barcode{i})*bestBarStretch(i)));
                bestStretchedBitmask{i} = bitmask{i}(round(linspace(1,length(barcode{i}),length(barcode{i})*bestBarStretch(i))));

                bestXcorr(i) = a;
    %             if mleculeStruct.filterSettings.filter == 1
                [a,b] = max(xcorrMax2);
                bestBarStretch2(i) = stretchFactors(b);
                stretchedBar2{i} = imgaussfilt(interp1(barcode{i}, linspace(1,length(barcode{i}),length(barcode{i})*bestBarStretch2(i))), filterSize);
    %                 if mleculeStruct.filterSettings.filterMethod == 1
    %                     stretchedBar2{i} = interp1(barcodeFiltered{i}, linspace(1,length(barcodeFiltered{i}),length(barcodeFiltered{i})*bestBarStretch2(i)));
    %                 else
    %                 end
    %                 
                comparisonStructure2{i} = xcorrs2{b};
                bestStretchedBitmask2{i} =  bitmask{i}(round(linspace(1,length(bitmask{i}),length(bitmask{i})*bestBarStretch2(i))));

                bestXcorr2(i) = a;
    %             end
             end
         end
    end
    
    mleculeStruct.comparisonStructure.xcorr = comparisonStructure;
    mleculeStruct.comparisonStructure.barStretch = bestBarStretch;
    mleculeStruct.comparisonStructure.StretchedBar = bestStretchedBar;
    mleculeStruct.comparisonStructure.StretchedBitmask = bestStretchedBitmask;
    mleculeStruct.comparisonStructure.bestXcorr = bestXcorr;
%     if mleculeStruct.filterSettings.filter == 1
    mleculeStruct.comparisonStructure2.xcorr = comparisonStructure2;
    mleculeStruct.comparisonStructure2.StretchedBar = stretchedBar2;
    mleculeStruct.comparisonStructure2.StretchedBitmask = bestStretchedBitmask2;
    mleculeStruct.comparisonStructure2.barStretch = bestBarStretch2;
     mleculeStruct.comparisonStructure2.bestXcorr2 = bestXcorr2;

%    end
    
    
    % later load from  hcaSessionStruct.theoryGen.sets
    %hcaSessionStruct.theoryGen.sets
  
%     import CBT.get_default_barcode_gen_settings;
%     barcodeGenSettings = get_default_barcode_gen_settings();
%     barcodeGenSettings = hcaSessionStruct.theoryGen.sets;
  
    %     

    %     % THESE SHOULD BE TAKEN FROM CBT.ini/ move them to comparison_settings.
%     import CBT.get_default_barcode_gen_settings;
%     barcodeGenSettings = get_default_barcode_gen_settings();
%     barcodeGenSettings = defaultBarcodeGenSettings;
%     barcodeGenSettings.pixelWidth_nm = 130;
%     barcodeGenSettings.psfSigmaWidth_nm=300;
%     barcodeGenSettings.isLinearTF = 0;
%     barcodeGenSettings.concNetropsin_molar = 6e-6; % Netropsin concentration, units molar
%     barcodeGenSettings.concYOYO1_molar = 2e-8; % YOYO-1 concentration, units molar
%    
%     barcodeGenSettings.meanBpExt_nm = 0.225;
% 

  
    

% 
%     import CA.CombAuc.Core.Zeromodel.generate_random_sequences;
%     import CA.CombAuc.Core.Comparison.compute_correlation;
%     import CA.CombAuc.Core.Comparison.generate_evd_par;
%     import CA.CombAuc.Core.Comparison.cc_fft;
% 
%     m = load('meanF.mat');
%     meanFFTest = interp1(m.meanFFT,linspace(1,length(m.meanFFT),m.len));
%     
%     % compute only one
%     expLen = round(mean(cellfun(@length,hcaSessionStruct.comparisonStructure.StretchedBar)));
%      [ randomSequences ] = generate_random_sequences(2*expLen,1000,meanFFTest, barcodeGenSettings.psfSigmaWidth_nm/(barcodeGenSettings.pixelWidth_nm/barcodeGenSettings.meanBpExt_nm ),'phase');
%     expB = ones(1,expLen);
%     for i=1:length(randomSequences)
%         randomSequences{i} = zscore(randomSequences{i}(1:end/2));
% 	  	[cc1,cc2] =CA.CombAuc.Core.Comparison.cc_fft(randomSequences{i}, hcaSessionStruct.theoryGen.theoryBarcodes{1}');
%         ccMax(i) = max([cc1(:);cc2(:)]);
% %         import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
% %         [xcorrs, coverageLens, firstOffset] = get_no_crop_lin_circ_xcorrs(randomSequences{i}, hcaSessionStruct.theoryGen.theoryBarcodes{1}', expB,hcaSessionStruct.theoryGen.bitmask{1});
% %         ccMax(i) =max(xcorrs(:));
%     end
%     [~,rSq,evdPar] = generate_evd_par( ccMax,[],length(randomSequences{1})/5, 'exact2' );
%     
%     hcaSessionStruct.comparisonStructure.evdPar = evdPar;

    %     %contigItems/aka fragments
%     evdPar = cell(1,length(hcaSessionStruct.comparisonStructure));
%     pValueMatrix = cell(1,length(hcaSessionStruct.comparisonStructure));
%    
%     % only compute for the first contig/molecule since it takes some time..
%     % later let user choose which ones..
%     for contigNum=1   
% 
%         %should we save randomsequences to resutls? since this has to be
%         %reproducible. but don't want too much things in the result
%         %structure..
%       %  expBit = ones(1,length(hcaSessionStruct.rawBarcodes{contigNum}));
%         ccMax = zeros(1,length(randomSequences));
%         for i=1:length(randomSequences)
%             randomSequences{i} = zscore(randomSequences{i}(1:end/2));
%             
%             [cc1,cc2] =CA.CombAuc.Core.Comparison.cc_fft(randomSequences{i}, hcaSessionStruct.theoryGen.theoryBarcodes{1}');
%             ccMax(i) = max([cc1(:);cc2(:)]);
%             % the comp with bitweights is 20 times slower for this...
% %             import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
% %             [xcorrs, coverageLens, firstOffset] = get_no_crop_lin_circ_xcorrs(randomSequences{i}, hcaSessionStruct.theoryGen.theoryBarcodes{1}, expBit,hcaSessionStruct.theoryGen.bitmask{1});
%         end
%        	[~,rSq,evdPar{contigNum}] = generate_evd_par( ccMax,[],length(randomSequences{1})/5, 'exact2' );
%       	%[cc1,cc2] = cc_fft(zscore(contigItems{contigNum}.barcode),refBarcode);
% 
%         %ccValueMatrix(contigNum,:) = [cc1 cc2];
%         import CBT.ExpComparison.Core.exact_full_PDF;
%         
%         pValueMatrix{contigNum} = compute_p_value(hcaSessionStruct.comparisonStructure{2}, evdPar{contigNum}, 'exact' );
% 
%     end



%     
%     barExp = hcaSessionStruct.consensusStruct.rawBarcode;
%     barExp = barThr(20000:20000+length(hcaSessionStruct.consensusStruct.rawBarcode-1));
%     barExpBitmask = hcaSessionStruct.consensusStruct.bitmask;
%     barExp = barExp(barExpBitmask);
%    % barThr = hcaSessionStruct.theoryBarcodes{1};
%     barThr =barcodePxRes;
%     barThrBitmask = ones(1,length(barThr));
%   
%     import CBT.get_default_barcode_gen_settings;
%     defaultBarcodeGenSettings = get_default_barcode_gen_settings();
%     barcodeGenSettings = defaultBarcodeGenSettings;
%     for kk=980
%         barcodeGenSettings.pixelWidth_nm = 171;
%         barcodeGenSettings.psfSigmaWidth_nm=500;
%        %barcodeGenSettings.psfSigmaWidth_nm = kk;
%         % seqq = fastaread('2330P18.fa');
%         import CBT.Core.gen_unscaled_cbt_barcode
%         bar = gen_unscaled_cbt_barcode(seqq.Sequence,barcodeGenSettings);
%          import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
%          [xcorrs, coverageLens, firstOffset] = get_no_crop_lin_circ_xcorrs(clusterConsensusData.barcode, bar, clusterConsensusData.bitmask,ones(1,length(bar)));
%          [kk max(xcorrs(:))]
%     end
%     
%     [~,id]=max(xcorrs(1,:));
%     figure,plot(zscore(bar))
%     hold on
%    
%     plot(id:id+length(clusterConsensusData.barcode)-1,clusterConsensusData.barcode)
%     
%     
%     
%     import CBT.Core.cb_netropsin_vs_yoyo1_plasmid;
%     concNetropsin_molar = barcodeGenSettings.concNetropsin_molar;
%     concYOYO1_molar = barcodeGenSettings.concYOYO1_molar;  
%     probsBinding = cb_netropsin_vs_yoyo1_plasmid(seqq.Sequence, concNetropsin_molar,  concYOYO1_molar);
%     % barThr will be bit-weighted
% % 
% %     x=load('Long.mat');
% %     y=load('Short.mat');
% % 
%     import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
% % 
% 
% barThr(barThr==0)=rand(1);
% tic
% tic
%    [cc1,cc2] = Comparison.cc_fft(zscore(barExp),barThr);
%    toc
%    cc1(find(isinf(real(cc1))))=zeros(1,length(find(isinf(real(cc1)))));
%     cc2(find(isinf(real(cc2))))=zeros(1,length(find(isinf(real(cc2)))));
%     cc1=real(cc1);
%     cc2=real(cc2);
%     toc
% 
%    
% tic
% leng=10000;
% tic
%     [xcorrs, coverageLens, firstOffset] = get_no_crop_lin_circ_xcorrs(barExp, barThr(1:leng), ones(1,length(barExp)), barThrBitmask(1:leng));
% toc
%     [xcorrs, coverageLens, firstOffset] = get_no_crop_lin_circ_xcorrs(barExp, barThr(1:leng), barExpBitmask, barThrBitmask(1:leng));
% toc
% 
%     xCorMat = [];
%     for i=1
%         linSeq = circshift(barExp,[0,-i]);
%         linSeqBitmask = circshift(barExpBitmask,[0,-i]);
%         circSeq = y.clusterConsensusData.barcode;
%         circSeqBitmask = y.clusterConsensusData.bitmask;
% 
%         [xcorrs, coverageLens, firstOffset] = get_no_crop_lin_circ_xcorrs(linSeq, circSeq, linSeqBitmask, circSeqBitmask);
%         xCorMat = [xCorMat; max(xcorrs)];
%     end

    % here we do linear vs circular or circular vs circular, but for the
    % beginning assume linear, and use xcorr. first look at what is useincc
    
    timePassed = toc;
    display(strcat(['Experiments were compared to theory in ' num2str(timePassed) ' seconds']));

end

