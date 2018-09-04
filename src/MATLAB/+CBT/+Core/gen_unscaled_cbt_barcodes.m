function [theoryCurvesUnscaled_pxRes] = gen_unscaled_cbt_barcodes(ntSeqs, barcodeGenSettings)
    if nargin < 2
        barcodeGenSettings = [];
    end
    if isempty(barcodeGenSettings)
        import CBT.get_default_barcode_gen_settings;
        defaultBarcodeGenSettings = get_default_barcode_gen_settings();
        barcodeGenSettings = defaultBarcodeGenSettings;
        warning('Using default barcode generation settings');
    end

    import CBT.Core.cb_netropsin_vs_yoyo1_plasmid;
    concNetropsin_molar = barcodeGenSettings.concNetropsin_molar;
    concYOYO1_molar = barcodeGenSettings.concYOYO1_molar;
    
    stretchFactor = 1;
    if isfield(barcodeGenSettings, 'stretchFactor')
        stretchFactor = barcodeGenSettings.stretchFactor;
    end
    
    import Microscopy.Simulate.Core.apply_point_spread_function;
    psfSigmaWidth_bps = barcodeGenSettings.psfSigmaWidth_nm / barcodeGenSettings.meanBpExt_nm;
    
    import CBT.Core.convert_bpRes_to_pxRes;
    meanBpExt_pixels = barcodeGenSettings.meanBpExt_nm / barcodeGenSettings.pixelWidth_nm;
    
    if not(isfield(barcodeGenSettings, 'isLinearTF')) || not(isfield(barcodeGenSettings, 'widthSigmasFromMean'))
        import CBT.get_default_barcode_gen_settings;
        defaultBarcodeGenSettings = get_default_barcode_gen_settings();
        barcodeGenSettings.isLinearTF = defaultBarcodeGenSettings.isLinearTF;
        barcodeGenSettings.widthSigmasFromMean = defaultBarcodeGenSettings.widthSigmasFromMean;
    end
    isLinearTF = barcodeGenSettings.isLinearTF;
    widthSigmasFromMean = barcodeGenSettings.widthSigmasFromMean;
    
    numSeqs = length(ntSeqs);
    theoryCurvesUnscaled_pxRes = cell(numSeqs, 1);
    for seqNum = 1:numSeqs
        ntSeq = ntSeqs{seqNum};
        
        % compute Netropsin & YOYO-1 binding probabilities
        probsBinding = cb_netropsin_vs_yoyo1_plasmid(ntSeq, concNetropsin_molar,  concYOYO1_molar);

        % YOYO-1 binding probabilities
        theoryProb_bpRes = probsBinding.Yoyo1;

        if (stretchFactor == 1)
            theoryCurve_bpRes_prePSF = theoryProb_bpRes;
        else
            theoryCurve_bpRes_prePSF = apply_stretching(theoryCurve_bpRes, stretchFactor);
        end

        % convolve with point spread function
        theoryBarcodePostPSF_bpRes = apply_point_spread_function(theoryCurve_bpRes_prePSF, psfSigmaWidth_bps, isLinearTF, widthSigmasFromMean);

        % sample barcode to pixel resolution
        theoryCurveUnscaled_pxRes = convert_bpRes_to_pxRes(theoryBarcodePostPSF_bpRes, meanBpExt_pixels);
        
        theoryCurvesUnscaled_pxRes{seqNum} = theoryCurveUnscaled_pxRes;
    end
end