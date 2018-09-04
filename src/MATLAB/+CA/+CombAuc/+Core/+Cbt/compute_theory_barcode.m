function [ theoryCurveUnscaled_pxRes, bitmask ] = compute_theory_barcode( prob,sets )
    % Computes theory barcode for hca
    
    % input 
    % prob
    % sets - settings
    
    % output 
    % barcode
    

    import Microscopy.Simulate.Core.apply_point_spread_function;
    psfSigmaWidth_bps = sets.barcodeConsensusSettings.psfSigmaWidth_nm / sets.meanBpExt_nm;

    import CBT.Core.convert_bpRes_to_pxRes;
    meanBpExt_pixels = sets.meanBpExt_nm / sets.barcodeConsensusSettings.prestretchPixelWidth_nm;

 
    import CA.CombAuc.Core.Zeromodel.gaussian_kernel;
    ker = gaussian_kernel(length(prob), psfSigmaWidth_bps);
    multF=conj(fft(ker))';

    
    theoryBar_bpRes = ifft(fft(prob).*multF); 
    probSeq = theoryBar_bpRes;
    
    theoryCurveUnscaled_pxRes = convert_bpRes_to_pxRes(probSeq, meanBpExt_pixels);

    bitmask = ones(1,length(theoryCurveUnscaled_pxRes));
end

