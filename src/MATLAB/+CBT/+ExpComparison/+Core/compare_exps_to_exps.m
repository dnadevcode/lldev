function [...
        pValMat, ...
        maxPCCsMat, ...
        flipMat, ...
        shortShiftMat, ...
        longShiftMat, ...
        stretchFactorsMat] = compare_exps_to_exps(...
            consensusBarcodes, ...
            consensusBitmasks, ...
            isPlasmid, ...
            consensusBarcodesKbpsPerPixel, ...
            sameLengthTF, ...
            stretchFactors, ...
            meanZeroModelFftFreqMags, ...
            zeroModelKbpsPerPixel, ...
            numRandBarcodes ...
        )
    %---Experiment comparison---
    % Get extreme value edistribution parameters
    numBarcodes = length(consensusBarcodes);
    gumbelFitParamsMat = zeros(numBarcodes, numBarcodes, 2);

    import CBT.RandBarcodeGen.PhaseRandomization.gen_rand_bp_ext_adjusted_zero_model_barcodes;
    import CBT.ExpComparison.Core.fit_gumbel_with_zero_model;
    for barcodeIdxB = 1:numBarcodes
        barcodeB = consensusBarcodes{barcodeIdxB};

        % Generate the random barcodes:
        refLen_pixels = length(barcodeB);
        randomBarcodes = gen_rand_bp_ext_adjusted_zero_model_barcodes(...
            numRandBarcodes, ...
            refLen_pixels, ...
            meanZeroModelFftFreqMags, ...
            zeroModelKbpsPerPixel, ...
            consensusBarcodesKbpsPerPixel ...
        );

        for barcodeIdxA = 1:numBarcodes
            
            if sameLengthTF && (barcodeIdxB <= barcodeIdxA)
                continue;
            end

            barcodeA = consensusBarcodes{barcodeIdxA};

            [gumbelCurveMu, gumbelCurveBeta] = fit_gumbel_with_zero_model(...
                barcodeA,...
                consensusBitmasks{barcodeIdxA},...
                randomBarcodes,...
                consensusBitmasks{barcodeIdxB},...
                stretchFactors,...
                not(isempty(stretchFactors) | isequal(stretchFactors, 1)),...
                isPlasmid,...
                sameLengthTF);
            gumbelFitParamsMat(barcodeIdxA, barcodeIdxB, :) = [gumbelCurveMu, gumbelCurveBeta];
        end
    end
    if sameLengthTF
        gumbelFitParamsMat = gumbelFitParamsMat + permute(gumbelFitParamsMat,[2 1 3]);
    end

    % Get P-value matrix
    pValMat = zeros(numBarcodes);
    maxPCCsMat = zeros(numBarcodes);
    shortShiftMat = zeros(numBarcodes);
    flipMat = zeros(numBarcodes);
    stretchFactorsMat = ones(numBarcodes);
    longShiftMat = zeros(numBarcodes);

    import CBT.ExpComparison.Core.GrossCcorr.ccorr_circcirc;
    import CBT.ExpComparison.Core.GrossCcorr.ccorr_all;
    import CBT.ExpComparison.Core.calculate_p_value;
    
    if not(isempty(stretchFactors))
        for barcodeIdxA = 1:numBarcodes
            for barcodeIdxB = 1:numBarcodes
                if barcodeIdxA == barcodeIdxB
                    continue;
                end
                tempBestCCMat = zeros(length(stretchFactors), 1);
                tempFlipMat = tempBestCCMat;
                tempLongShiftMat = tempBestCCMat;
                tempShortShiftMat = tempBestCCMat;
                jStretch = 1;
                for stretchFactor = stretchFactors
                    barcodeTemp = interp1(consensusBarcodes{barcodeIdxA},linspace(1,length(consensusBarcodes{barcodeIdxA}),round(stretchFactor*length(consensusBarcodes{barcodeIdxA}))));
                    [...
                        tempBestCCMat(jStretch), ...
                        tempFlipMat(jStretch), ...
                        tempLongShiftMat(jStretch), ...
                        tempShortShiftMat(jStretch) ...
                    ] = ccorr_circcirc(barcodeTemp,consensusBarcodes{barcodeIdxB});
                    jStretch = jStretch + 1;
                end
                [tempMaxPCC, tempMaxPCCIdx] = max(tempBestCCMat);
                maxPCCsMat(barcodeIdxA, barcodeIdxB) = tempMaxPCC(1);
                flipMat(barcodeIdxA, barcodeIdxB) = tempFlipMat(tempMaxPCCIdx);
                longShiftMat(barcodeIdxA, barcodeIdxB) = tempLongShiftMat(tempMaxPCCIdx);
                shortShiftMat(barcodeIdxA, barcodeIdxB) = tempShortShiftMat(tempMaxPCCIdx);
                stretchFactorsMat(barcodeIdxA, barcodeIdxB) = stretchFactors(tempMaxPCCIdx);

                gumbelCurveMu = gumbelFitParamsMat(barcodeIdxA, barcodeIdxB, 1);
                gumbelCurveBeta = gumbelFitParamsMat(barcodeIdxA, barcodeIdxB, 2);
                bestCC = maxPCCsMat(barcodeIdxA, barcodeIdxB);

                pValMat(barcodeIdxA, barcodeIdxB) = calculate_p_value(gumbelCurveMu, gumbelCurveBeta, bestCC);
            end
        end
    else
        shouldRescaleTF = true;
        for barcodeIdxA = 1:numBarcodes
            for barcodeIdxB = 1:barcodeIdxA-1
                barcodeA = consensusBarcodes{barcodeIdxA};
                barcodeB = consensusBarcodes{barcodeIdxB};

                if not(sameLengthTF)
                    [ccVal, flipVal, longShiftVal, shortShiftVal] = ccorr_circcirc(...
                        barcodeA, ...
                        barcodeB ...
                    );
                    longShiftMat(barcodeIdxA, barcodeIdxB) = longShiftVal;
                else
                    [tempMaxPCC, ~, flipVal, shortShiftVal] = ccorr_all(...
                        barcodeA, ...
                        barcodeB, ...
                        isPlasmid, ...
                        shouldRescaleTF ...
                    );
                    ccVal = max(tempMaxPCC);
                end
                maxPCCsMat(barcodeIdxA, barcodeIdxB) = ccVal;
                flipMat(barcodeIdxA, barcodeIdxB) = flipVal;
                shortShiftMat(barcodeIdxA, barcodeIdxB) = shortShiftVal;

                gumbelCurveMu_ab = gumbelFitParamsMat(barcodeIdxA, barcodeIdxB,1);
                gumbelCurveMu_ba = gumbelFitParamsMat(barcodeIdxB, barcodeIdxA,1);

                gumbelCurveBeta_ab = gumbelFitParamsMat(barcodeIdxA, barcodeIdxB,2);
                gumbelCurveBeta_ba = gumbelFitParamsMat(barcodeIdxB, barcodeIdxA,2);

                bestCC = maxPCCsMat(barcodeIdxA, barcodeIdxB);

                pVal_ab = calculate_p_value(gumbelCurveMu_ab, gumbelCurveBeta_ab, bestCC);
                pVal_ba = calculate_p_value(gumbelCurveMu_ba, gumbelCurveBeta_ba, bestCC);

                pValMat(barcodeIdxA, barcodeIdxB) = pVal_ab;
                pValMat(barcodeIdxB, barcodeIdxA) = pVal_ba;
            end
        end
        maxPCCsMat = maxPCCsMat + maxPCCsMat' - diag(diag(maxPCCsMat));
        flipMat = flipMat + flipMat' - diag(diag(flipMat));
        shortShiftMat = shortShiftMat + shortShiftMat' - diag(diag(shortShiftMat));
        if not(sameLengthTF)
            longShiftMat = longShiftMat + longShiftMat' - diag(diag(longShiftMat));
        end
    end
end