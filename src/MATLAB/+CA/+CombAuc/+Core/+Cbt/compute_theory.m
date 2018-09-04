function [ barcodePxRes,bitmaskPxRes,barcodeBpRes,bitmaskBpRes ] = compute_theory( theorySeq,sets,model )
    % Computes theory barcode for hca
    
    % input 
    % theorySeq
    % sets - settings
    
    % output 
    % barcode
  
    % theory parameters
    YOYO1conc = sets.defaultBarcodeGenSettings.concYOYO1_molar;
    NETROPSINconc = sets.defaultBarcodeGenSettings.concNetropsin_molar;
    K = sets.defaultBarcodeGenSettings.yoyo;
    
    % binding probability
    if isequal(model.name,'literature')
        [prob] = CA.CombAuc.Core.Cbt.cb_transfer_matrix_literature(theorySeq,NETROPSINconc,YOYO1conc,K,model.netropsinBindingConstant,1000 );
    else
        oMat = diag([0,0,0,0,0,1,1,1,1]);
        [prob] = CA.CombAuc.Core.Cbt.cb_transfer_matrix_editable(theorySeq,NETROPSINconc,YOYO1conc,K,model.netropsinBindingConstant,1000 ,oMat);
    end
    
    % point spread function width in bp
    psfSigmaWidth_bps = sets.barcodeConsensusSettings.psfSigmaWidth_nm / sets.meanBpExt_nm;

    % bp to pixel convertion ration
    meanBpExt_pixels = sets.meanBpExt_nm / sets.barcodeConsensusSettings.prestretchPixelWidth_nm;

    % gaussian kernel in bp res.
    import CA.CombAuc.Core.Zeromodel.gaussian_kernel;
    ker = gaussian_kernel(length(prob), psfSigmaWidth_bps);
    
    multF=conj(fft(ker))';

    % convolve with Gaussian kernel to get a barcode in basepair resolution
    barcodeBpRes = ifft(fft(prob).*multF); 
     
    % get the bitmask in bp resolution
    bitmaskBpRes = logical(ones(1,length(barcodeBpRes)));
    
    % in case of linearity edge pixels are bitmasked
    if sets.defaultBarcodeGenSettings.isLinearTF ==1
        untrustedBp = round(sets.barcodeConsensusSettings.deltaCut*psfSigmaWidth_bps);
        if untrustedBp > length(bitmaskBpRes)
            bitmaskBpRes = zeros(1,length(bitmaskBpRes));
        end
        bitmaskBpRes(1:untrustedBp) = zeros(1,untrustedBp);
        bitmaskBpRes(end-untrustedBp+1:end) = zeros(1,untrustedBp);
    end

    % convert to px resolution
    import CBT.Core.convert_bpRes_to_pxRes;
    barcodePxRes = convert_bpRes_to_pxRes(barcodeBpRes, meanBpExt_pixels);
    
    % same with bitmask.
    v = linspace(1, length(bitmaskBpRes),  length(barcodePxRes));
    bitmaskPxRes = bitmaskBpRes(round(v));
end

