function [ randomSequences ] = gen_rand_seq(lengthOfSequences,numberOfSequences,inputData,psfSigmaWidth, method,pxPerBp)
    % 27/10/16
    % generates a set of stationary gaussian processes following a given
    % autocorrelation function
    % based on "Fast simulation of stationary gaussian processes", pg 1091
    
    % example ->
    % seqLen = 40 %- the length of the output sequence
    % seqNum = 100 %- 2*seqNum is the number of sequences outputed
    % method = 'power' %- what is the autocorrelation function like?
    % alpha = 2 % autocorrelation function parameter
    
    % [ randomSequences ] = generate_autocorr_rand_seq(seqLen,seqNum,method, barcode,alpha )
    
    %
    if nargin < 5 % if no method was selected
        method = 'phase';
    end
    
    import CA.CombAuc.Core.Zeromodel.gaussian_kernel;
    ker = gaussian_kernel(lengthOfSequences,psfSigmaWidth);
    kerC = conj(fft((ker)));
    
    % include all possible random sequence models
    switch method
		case 'phase'			
            randomSequences = cell(1,numberOfSequences);

            % alternative to methods before... check how well it works!
            import CA.CombAuc.Core.Numeric.interpolate_in_fourier_space_random
            [interpData] = interpolate_in_fourier_space_random( inputData, lengthOfSequences );
        
            halfL = floor(lengthOfSequences/2);
            
            parfor i=1:numberOfSequences
                PR1 = exp(2i*pi*rand(1,halfL));
                PR2 = fliplr(conj(PR1));

                if mod(lengthOfSequences,2)==0
                    PR = [1 PR1(1:end-1) 1 PR2(2:end)];
                else
                     PR = [1 PR1 PR2];
                end
                
                % we can choose first and second moments we want, whatever they
                % may be. Should we do only one interpolation?
                newMean = 0.5+0.2*rand(1); % allow to choose these parameters based on meanfft results
                newVar = 0.2+0.1*rand(1);
                import CA.CombAuc.Core.Numeric.rescale_in_fourier_space
                newInterpolatedData =rescale_in_fourier_space( interpData,newMean, newVar );
            
                randSeq = ifft((newInterpolatedData.*PR).*kerC);
                     
                import CBT.Core.convert_bpRes_to_pxRes;
                randomSequences{i} = convert_bpRes_to_pxRes(randSeq, pxPerBp);
            end
            return;
		case 'random'
            % in case completely random model is selected, just draw seqLen
            % numbers from normrnd seqNum times
			randomSequences = cell(1,numberOfSequences);
			for i=1:numberOfSequences
				randomSequences{i} = imgaussfilt(normrnd(0,1,1,lengthOfSequences),psfSigmaWidth/130);
			end
			return;
            
        otherwise
            randomSequences = [];
            warning('Unexpected choice of randomisation method')
            return;
    end
     
end

