function featureDetectionSettings = get_default_feature_detection_settings()
    import OptMap.KymoAlignment.generate_filter_fn;
    
    gaussianFilterSettings.filterSize = [10, 10];
    gaussianFilterSettings.gaussianKernelSigma = 2;
    gaussianFilterSettings.useEdgeExtension = true;

    featureDetectionSettings.typicalFeatureHalfwidth = 5;
    featureDetectionSettings.maxMovementPx = 3;
    featureDetectionSettings.maxNumFeatures = Inf;
    featureDetectionSettings.filter.gaussian = gaussianFilterSettings;
    featureDetectionSettings.fn.apply_gaussian_filter = generate_filter_fn('gaussian',...
        gaussianFilterSettings.filterSize,...
        gaussianFilterSettings.gaussianKernelSigma,...
        gaussianFilterSettings.useEdgeExtension);

    logFilterSettings.filterSize = [2, 6];
    logFilterSettings.gaussianKernelSigma = 2;
    logFilterSettings.useEdgeExtension = true;
    filtrationSettings.filter.LoG = logFilterSettings;
    filtrationSettings.fn.apply_LoG_filter = generate_filter_fn('log',...
        logFilterSettings.filterSize,...
        logFilterSettings.gaussianKernelSigma,...
        logFilterSettings.useEdgeExtension);
    featureDetectionSettings.filtrationSettings = filtrationSettings;
end