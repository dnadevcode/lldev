function [aborted, consensusInputs] = get_consensus_inputs(displayNames, rawBarcodes, bpsPerPx_original)
    consensusInputs = struct();

    rawBarcodeLens = cellfun(@length, rawBarcodes);
    commonLength = ceil(mean(rawBarcodeLens));
    import CBT.Consensus.Import.confirm_stretching_is_ok;
    [notOK, commonLength] = confirm_stretching_is_ok(commonLength, rawBarcodeLens);
    aborted = notOK;
    if aborted
        fprintf('Aborting consensus input generation\n');
        return;
    end

    import CBT.Consensus.Import.get_default_consensus_settings;
    [defaultConsensusSettings, dbmSettingsStruct] = get_default_consensus_settings();

    import CBT.Consensus.Import.get_cluster_threshold;
    [clusterScoreThresholdNormalized, quitConsensus] = get_cluster_threshold(defaultConsensusSettings);
    aborted = quitConsensus;
    if aborted
        fprintf('Aborting consensus input generation\n');
        return;
    end

    import CBT.Consensus.Import.get_prestretch_params;
    [prestretchUntrustedEdgeLenUnrounded_pixels, prestretchPixelWidth_nm] = get_prestretch_params(dbmSettingsStruct);
    
    import CBT.Consensus.Import.Helper.gen_consensus_inputs_struct;
    consensusInputs = gen_consensus_inputs_struct(displayNames, rawBarcodes, bpsPerPx_original, clusterScoreThresholdNormalized, commonLength, prestretchUntrustedEdgeLenUnrounded_pixels, prestretchPixelWidth_nm);
end