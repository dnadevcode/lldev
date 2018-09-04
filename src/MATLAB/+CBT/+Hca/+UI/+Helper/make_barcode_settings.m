function [commonLength,aborted] = make_barcode_settings(rawBarcodeLens)
%     import CBT.Consensus.Import.get_default_consensus_settings;
%     [defaultConsensusSettings, dbmSettingsStruct] = get_default_consensus_settings();
% 
%     barcodeConsensusSettings = defaultConsensusSettings;
% 
%     import CBT.Consensus.Import.get_prestretch_params;
%     [prestretchUntrustedEdgeLenUnrounded_pixels, prestretchPixelWidth_nm] = get_prestretch_params(dbmSettingsStruct);
% 
%     barcodeConsensusSettings.prestretchUntrustedEdgeLenUnrounded_pixels = prestretchUntrustedEdgeLenUnrounded_pixels;
%     barcodeConsensusSettings.prestretchPixelWidth_nm = prestretchPixelWidth_nm;

    commonLength = ceil(mean(rawBarcodeLens));

    import CBT.Consensus.Import.confirm_stretching_is_ok;
    [notOK, commonLength] = confirm_stretching_is_ok(commonLength, rawBarcodeLens);
    aborted = notOK;
    if aborted
       % clusterScoreThresholdNormalized = [];
        fprintf('Skipping consensus generation\n');
        %barcodeConsensusSettings = [];
        return;
    end
    %barcodeConsensusSettings.commonLength = commonLength;

   
    if aborted
       % clusterScoreThresholdNormalized = [];
        fprintf('Aborting consensus input generation\n');
        %barcodeConsensusSettings = [];
        return;
    end
   % barcodeConsensusSettings.clusterScoreThresholdNormalized = clusterScoreThresholdNormalized;
end