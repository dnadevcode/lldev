function [ vecPxRes,bitmask ] = create_ps_barcode( seq, sets )
    % create_ps_barcode
    % This function creates a melting map based on the Poland-Scheraga
    % model
    
    % input
    % seq, sets
    
    % output
    % theorySeq,bitmask

    % temperature and salt concentration
    temperature_Celsius = sets.temp;
    saltConc_Molar = sets.saltConc; 
    
    % compute the melting map probabilities
    import MMT.Core.calculate_nonmelting_probs;
    vec = calculate_nonmelting_probs(seq, temperature_Celsius, saltConc_Molar); 
     
    % convolve with a Gaussian
    import MMT.Zeromodel.gaussian_kernel;
    ker = gaussian_kernel(length(seq), sets.psfSigmaWidth_nm/sets.meanBpExt_nm);
    multF=conj(fft(ker));
    vecBpRes= ifft(fft(vec').*multF); 

    % convert ot pixel resolution
    import CBT.Core.convert_bpRes_to_pxRes;
    meanBpExt_pixels = sets.meanBpExt_nm / sets.pixelWidth_nm;
    vecPxRes = convert_bpRes_to_pxRes(vecBpRes, meanBpExt_pixels);
         
    % if there are no restrictions, bitmask is all 1'nes
    bitmask = ones(1,length(vecPxRes));
end

