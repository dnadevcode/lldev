function [ hcaSessionStruct ] = convert_nm_ratio( newNmBp,hcaSessionStruct,sets )
    % this function converts one nm/bp ratio (standard is 0.3) to another
    % (for example 0.2).
    
    % This uses the fact that convolution fo two Gaussians is a Gaussian.
    % See http://mathworld.wolfram.com/Convolution.html for details,
    % i.e. sigma_1^2+x^2 = sigma^2. So, knowing sigma_1 and sigma_2,
    % we can easily compute the unknown width x, and then just convolve
    % with it
    
    for i=1:length(hcaSessionStruct.theoryGen.theoryBarcodes)
    % first change nm to bp ratio
        seq = hcaSessionStruct.theoryGen.theoryBarcodes{i};

        % first convert to the correct length
        pxSize = hcaSessionStruct.theoryGen.sets.meanBpExt_nm/newNmBp;

        import CBT.Core.convert_bpRes_to_pxRes;
        seq = convert_bpRes_to_pxRes(seq, 1/pxSize);
        hcaSessionStruct.theoryGen.bitmask{i} = convert_bpRes_to_pxRes(hcaSessionStruct.theoryGen.bitmask{i}, 1/pxSize);
        sigma1 =  sets.barcodeGenSettings.psfSigmaWidth_nm/sets.barcodeGenSettings.pixelWidth_nm;
        
        sigma = pxSize*sets.barcodeGenSettings.psfSigmaWidth_nm/sets.barcodeGenSettings.pixelWidth_nm;
        
        % size of final sigma
        sigmaDif = sqrt(sigma^2-sigma1^2);
       
        % length of kernel
        hsize = size(seq,2);
   
        % kernel
        ker = circshift(images.internal.createGaussianKernel(sigmaDif, hsize),round(hsize/2));   
        
        % conjugate of kernel in phase space
        multF=conj(fft(ker'));

        % convolved with sequence ->
        hcaSessionStruct.theoryGen.theoryBarcodes{i} = ifft(fft(seq).*multF); 

    end
end

