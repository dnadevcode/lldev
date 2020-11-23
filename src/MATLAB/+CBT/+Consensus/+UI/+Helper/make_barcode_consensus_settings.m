function barcodeConsensusSettings = make_barcode_consensus_settings(rawBarcodeLens)
    import CBT.Consensus.Import.get_default_consensus_settings;
    [defaultConsensusSettings, dbmSettingsStruct] = get_default_consensus_settings();

    barcodeConsensusSettings = defaultConsensusSettings;

    import CBT.Consensus.Import.get_prestretch_params;
    [prestretchUntrustedEdgeLenUnrounded_pixels, prestretchPixelWidth_nm] = get_prestretch_params(dbmSettingsStruct);

    barcodeConsensusSettings.prestretchUntrustedEdgeLenUnrounded_pixels = prestretchUntrustedEdgeLenUnrounded_pixels;
    barcodeConsensusSettings.prestretchPixelWidth_nm = prestretchPixelWidth_nm;

    if barcodeConsensusSettings.promptSplitBasedOnLength
        if length(rawBarcodeLens) > barcodeConsensusSettings.maxNumBarcodesInCluster
            % select length range factor
            import OptMap.Consensus.Import.confirm_split_by_lengths;
            [notOK,barcodeConsensusSettings] = confirm_split_by_lengths(rawBarcodeLens,barcodeConsensusSettings);
            
        else  % default: run pair-wise comparisons for all of the barcodes.      
            commonLength = ceil(mean(rawBarcodeLens));
            import CBT.Consensus.Import.confirm_stretching_is_ok;
            [notOK, commonLength] = confirm_stretching_is_ok(commonLength, rawBarcodeLens);
            aborted = notOK;
            if aborted
                fprintf('Aborting consensus input generation\n');
                barcodeConsensusSettings = [];
                return;
            end
            barcodeConsensusSettings.lC = ones(1,length(rawBarcodeLens));
            barcodeConsensusSettings.commonLength = commonLength;        
        end
    end
  

    import CBT.Consensus.Import.get_cluster_threshold;
    [clusterScoreThresholdNormalized, quitConsensus] = get_cluster_threshold(defaultConsensusSettings);
    aborted = quitConsensus;
    if aborted
        fprintf('Aborting consensus input generation\n');
        barcodeConsensusSettings = [];
        return;
    end
    
    barcodeConsensusSettings.clusterScoreThresholdNormalized = clusterScoreThresholdNormalized;
end