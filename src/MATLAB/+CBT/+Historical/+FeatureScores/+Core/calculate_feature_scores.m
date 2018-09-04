function [featureScores, featureScoreDensities] = calculate_feature_scores(theorySequences, barcodeGenSettings)
    if nargin < 2
        import CBT.get_default_barcode_gen_settings;
        barcodeGenSettings = get_default_barcode_gen_settings();

        warning('Using default barcode generation settings:');
        disp(barcodeGenSettings);
    end

    numTheories = length(theorySequences);
    
    import CBT.Core.gen_zscaled_cbt_barcodes;
    theoryCurvesZscaled_pxRes = gen_zscaled_cbt_barcodes(theorySequences, barcodeGenSettings);
    
    %  ratiosAT
    %    the AT-concentrations (#A and T/total number of bases)
    import CBT.Historical.FeatureScores.Core.get_AT_richness;
    ratiosAT = cellfun(@get_AT_richness, theorySequences(:));
    

    %  numSigmas
    %    multiple of deviation that is to be used as an energy barrier
    %    threshold when detecting extrema for info score
    numSigmas = 2;
    
    % Find the std in the intensity of a barcode with that AT-concentration
    import CBT.Historical.FeatureScores.Import.get_eCISs3_std_approx;
    approxStds = arrayfun(@get_eCISs3_std_approx, ratiosAT);

    % % historically, double the numSigma was multiplied, but that
    % %   doesn't really seem to make sense, commented out:
    % minValDistBetweenAdjExtrema = 2 * numSigmas .* approxStds;
    minValDistsBetweenAdjExtrema = numSigmas .* approxStds;
    
    import CBT.Historical.FeatureScores.Core.cb_calcinfotheory_fs;
    featureScores = arrayfun(@(theoryNum, minValDistBetweenAdjExtrema) ...
        cb_calcinfotheory_fs(theoryCurvesZscaled_pxRes{theoryNum}, minValDistBetweenAdjExtrema), ...
        (1:numTheories)', minValDistsBetweenAdjExtrema);
    
    sequenceLengths = cellfun(@length, theorySequences(:));
    featureScoreDensities = featureScores./sequenceLengths;
end