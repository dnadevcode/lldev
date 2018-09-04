function [ randomBarcodes ] = generate_random_sequences(refLenPixels, sets)
    % generate_random_sequences
    
    % input refLenPixels, sets
    % output randomSequences
      
    if sets.zeroModelResolution == 0
        % bp per pixel
        bpPerPx = sets.prestretchPixelWidth_nm/sets.meanBpExt_nm;
        pxPerBp = sets.meanBpExt_nm/sets.prestretchPixelWidth_nm;
        % psf in pixels
        psfSigmaWidth = sets.psfSigmaWidth_nm/sets.meanBpExt_nm;

        % barcode length in bp
        refLenBp = ceil(refLenPixels*bpPerPx);

        % Compute psf kernel
        import CA.CombAuc.Core.Zeromodel.gaussian_kernel;
        ker = gaussian_kernel(refLenBp,psfSigmaWidth);
        kerC = conj(fft((ker)));
   
        randomBarcodes = cell(1, sets.numRandBarcodes);

        % alternative to methods before... check how well it works!
        import CBT.RandBarcodeGen.PhaseRandomization.interpolate_in_fourier_space_random
        [interpZeroModelFft] = interpolate_in_fourier_space_random( sets.meanZeroModelFftFreqMags, refLenBp );

        halfL = floor(refLenBp/2);

        parfor i=1:sets.numRandBarcodes
            PR1 = exp(2i*pi*rand(1,halfL));
            PR2 = fliplr(conj(PR1));

            if mod(refLenBp,2)==0
                PR = [1 PR1(1:end-1) 1 PR2(2:end)];
            else
                 PR = [1 PR1 PR2];
            end

            % choose so than barcodes are z-scored
            newMean = 0; % allow to choose these parameters based on meanfft results
            newVar = 1;
            import  CBT.RandBarcodeGen.PhaseRandomization.rescale_in_fourier_space
            newInterpolatedData =rescale_in_fourier_space( interpZeroModelFft,newMean, newVar );

            randSeq = ifft((newInterpolatedData.*PR).*kerC);

            import CBT.Core.convert_bpRes_to_pxRes;
            randomBarcodes{i} = convert_bpRes_to_pxRes(randSeq, pxPerBp);
        end       
    else
        randomBarcodes = CBT.RandBarcodeGen.PhaseRandomization.gen_rand_bp_ext_adjusted_zero_model_barcodes(...
        sets.numRandBarcodes, ...
        refLenPixels, ...
        sets.meanZeroModelFftFreqMags, ...
        sets.zeroModelKbpsPerPixel, ...
        sets.stretchedKbpsPerPixel);      
    end   
end

