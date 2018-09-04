function [comparisonResults] = compare_exps_vs_exps_bitmasked(consensusBarcodes, consensusBitmasks, eteSettings)
    % compare_exps_vs_exps_bitmasked
    
    % input
    % consensusBarcodes - consensus barcodes 
    % consensusBitmasks  - consensus bitmasks
    % eteSettings  - ete settings
    
    % output
    % comparisonResults - comparison results put in a nice structure
    
    % edited by Albertas Dvirnas 05/10/17
    
    %---Experiment comparison---
    disp('Started comparing experiments...');
    % Get extreme value edistribution parameters
    numBarcodes = length(consensusBarcodes);
   % evdFitParams = cell(numBarcodes,numBarcodes);   % Some preprocessing
      evdFitParams = zeros(numBarcodes, numBarcodes, 2);


    import CBT.RandBarcodeGen.PhaseRandomization.gen_rand_bp_ext_adjusted_zero_model_barcodes;
    import CBT.ExpComparison.Core.fit_with_zero_model;
    for barcodeIdxB = 1:numBarcodes   
        barcodeB = consensusBarcodes{barcodeIdxB};
        refLenPixels = length(barcodeB);

        % Generate the random barcodes:
        import CBT.RandBarcodeGen.PhaseRandomization.generate_random_sequences;
        [randomBarcodes] = generate_random_sequences(refLenPixels, eteSettings);
        %
        for barcodeIdxA = 1:numBarcodes
            
            % do not compare the barcode with itself
            if sameLengthTF && (barcodeIdxB <= barcodeIdxA)
                continue;
            end

            barcodeA = consensusBarcodes{barcodeIdxA};

            [evdPar] = fit_with_zero_model(...
                barcodeA,...
                consensusBitmasks{barcodeIdxA},...
                randomBarcodes,...
                consensusBitmasks{barcodeIdxB},...
                eteSettings.stretchFactors,eteSettings.fitModel);
            evdFitParams(barcodeIdxA, barcodeIdxB, :) = [evdPar(1), evdPar(2)];
        end
    end
      if sameLengthTF
        evdFitParams = evdFitParams + permute(evdFitParams,[2 1 3]);
      end
    
      
    ccValueMatrix = zeros(numBarcodes,numBarcodes);
    pValueMatrix = ones(numBarcodes,numBarcodes);
	flipMat = zeros(numBarcodes);
    stretchFactorsMat = ones(numBarcodes);
    shortShiftMat = zeros(numBarcodes);
    longShiftMat = zeros(numBarcodes);
    
	for barcodeIdxA = 1:numBarcodes
        for barcodeIdxB = 1:numBarcodes
            if barcodeIdxA == barcodeIdxB
                continue;
            end
            bar1 = consensusBarcodes{barcodeIdxA};
            bar2 = consensusBarcodes{barcodeIdxB};
            bit1 = consensusBitmasks{barcodeIdxA};
            bit2 = consensusBitmasks{barcodeIdxB};
            
            tempBestCCMat = zeros(length(eteSettings.stretchFactors), 1);
            tempFlipMat = tempBestCCMat;
            tempLongShiftMat = tempBestCCMat;
            tempShortShiftMat = tempBestCCMat;
            
            for j=1:length(eteSettings.stretchFactors)
            	bar1 = interp1(bar1, linspace(1,length(bar1),length(bar1)*eteSettings.stretchFactors(j)));
                bit1 = bit1(round(linspace(1,length(bit1),length(bit1)*eteSettings.stretchFactors(j))));

                xSecond = zeros(1,length(bar2));
                xFirst = zeros(1,length(bar1));
                longShift = zeros(1,length(bar2));

                if length(bar1) > length(bar2)
                    parfor shift=1:length(bar2)
                       xcorrs = SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs(circshift(bar2,[0 shift]), bar1,bit2,bit1);
                       [a,b] = max(xcorrs);
                       [xSecond(shift), longShift(shift)]= max(a);
                       bitV(shift) =  b(longShift(shift));
                    end
                else
                    parfor shift=1:length(bar1)
                       xcorrs = SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs(circshift(bar1,[0 shift]), bar2,bit1,bit2);
                       [a,b] = max(xcorrs);
                       [xFirst(shift),longShift(shift)]= max(a);
                       bitV(shift) =  b(longShift(shift));
                    end
                end
                [a,b] = max(xFirst);
                [c,d] = max(xSecond);
                [tempBestCCMat(j),idx] = max([a c]);
                if idx==1
                    tempShortShiftMat(j) = d;
                    tempLongShiftMat(j) = longShift(tempShortShiftMat(j));
                else
                    tempShortShiftMat(j) = b;
                    tempLongShiftMat(j) = longShift(tempShortShiftMat(j)); 
                end
                tempFlipMat(j) = bitV(tempLongShiftMat(j));
            end
            
            [maxx, maxId] = max(tempBestCCMat);
            stretchFactorsMat(barcodeIdxA,barcodeIdxB) = maxId;
            flipMat(barcodeIdxA,barcodeIdxB) = tempFlipMat(maxId);
            shortShiftMat(barcodeIdxA,barcodeIdxB) = tempShortShiftMat(maxId);
            longShiftMat(barcodeIdxA,barcodeIdxB) = tempLongShiftMat(maxId);
            ccValueMatrix(barcodeIdxA,barcodeIdxB) = maxx;
            pValueMatrix(barcodeIdxA,barcodeIdxB) = CA.CombAuc.Core.Comparison.compute_p_value(maxx,evdFitParams{barcodeIdxA, barcodeIdxB},eteSettings.fitModel); 
        end
    end
    

 
            
% 
%     % Get P-value matrix
%     pValMat = zeros(numBarcodes);
%     maxPCCsMat = zeros(numBarcodes);
%     shortShiftMat = zeros(numBarcodes);
%     flipMat = zeros(numBarcodes);
%     stretchFactorsMat = ones(numBarcodes);
%     longShiftMat = zeros(numBarcodes);
% 
%     
%     
%     import CBT.ExpComparison.Core.GrossCcorr.ccorr_circcirc;
%     import CBT.ExpComparison.Core.GrossCcorr.ccorr_all;
%     import CBT.ExpComparison.Core.calculate_p_value;
%     for barcodeIdxA = 1:numBarcodes
%         for barcodeIdxB = 1:numBarcodes
%             if barcodeIdxA == barcodeIdxB
%                 continue;
%             end
%             tempBestCCMat = zeros(length(stretchFactors), 1);
%             tempFlipMat = tempBestCCMat;
%             tempLongShiftMat = tempBestCCMat;
%             tempShortShiftMat = tempBestCCMat;
%             jStretch = 1;
%             for stretchFactor = stretchFactors
%                 barcodeTemp = interp1(consensusBarcodes{barcodeIdxA},linspace(1,length(consensusBarcodes{barcodeIdxA}),round(stretchFactor*length(consensusBarcodes{barcodeIdxA}))));
%                 [...
%                     tempBestCCMat(jStretch), ...
%                     tempFlipMat(jStretch), ...
%                     tempLongShiftMat(jStretch), ...
%                     tempShortShiftMat(jStretch) ...
%                 ] = ccorr_circcirc(barcodeTemp,consensusBarcodes{barcodeIdxB});
%                 jStretch = jStretch + 1;
%             end
%             [tempMaxPCC, tempMaxPCCIdx] = max(tempBestCCMat);
%             maxPCCsMat(barcodeIdxA, barcodeIdxB) = tempMaxPCC(1);
%             flipMat(barcodeIdxA, barcodeIdxB) = tempFlipMat(tempMaxPCCIdx);
%             longShiftMat(barcodeIdxA, barcodeIdxB) = tempLongShiftMat(tempMaxPCCIdx);
%             shortShiftMat(barcodeIdxA, barcodeIdxB) = tempShortShiftMat(tempMaxPCCIdx);
%             stretchFactorsMat(barcodeIdxA, barcodeIdxB) = stretchFactors(tempMaxPCCIdx);
% 
%             gumbelCurveMu = evdFitParams(barcodeIdxA, barcodeIdxB, 1);
%             gumbelCurveBeta = evdFitParams(barcodeIdxA, barcodeIdxB, 2);
%             bestCC = maxPCCsMat(barcodeIdxA, barcodeIdxB);
% 
%             pValMat(barcodeIdxA, barcodeIdxB) = calculate_p_value(gumbelCurveMu, gumbelCurveBeta, bestCC);
%         end
%     
%     
%         maxPCCsMat = maxPCCsMat + maxPCCsMat' - diag(diag(maxPCCsMat));
%         flipMat = flipMat + flipMat' - diag(diag(flipMat));
%         shortShiftMat = shortShiftMat + shortShiftMat' - diag(diag(shortShiftMat));
%         if not(sameLengthTF)
%             longShiftMat = longShiftMat + longShiftMat' - diag(diag(longShiftMat));
%         end
%     end
    
    % 
    comparisonResults = struct();
    comparisonResults.pValueMatrix = pValueMatrix;
    comparisonResults.ccValueMatrix = ccValueMatrix;
    comparisonResults.evdFitParams = evdFitParams;
    comparisonResults.flipMat = flipMat;
    comparisonResults.stretchFactorsMat = stretchFactorsMat;
    comparisonResults.shortShiftMat = shortShiftMat;
    comparisonResults.longShiftMat = longShiftMat;

    
%     comparisonResults.pValMat = pValMat;
%     comparisonResults.maxPCCsMat = maxPCCsMat;
%     comparisonResults.flipMat = flipMat;
%     comparisonResults.shortShiftMat = shortShiftMat;
%     comparisonResults.longShiftMat = longShiftMat;
%     comparisonResults.stretchFactorsMat = stretchFactorsMat;
end