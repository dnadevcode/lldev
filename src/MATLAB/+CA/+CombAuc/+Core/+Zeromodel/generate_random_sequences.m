function [ randomSequences ] = generate_random_sequences(lengthOfSequences,numberOfSequences,inputData,psfSigmaWidth, method)
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

    % include all possible random sequence models
    switch method
		case 'phase'			
            randomSequences = cell(1,numberOfSequences);

            import CA.CombAuc.Core.Numeric.interpolate_in_fourier_space_fix
            
            [interpData] = interpolate_in_fourier_space_fix( inputData, lengthOfSequences );
            %figure,plot(interpData)

            %           randomSequences= CBT.RandBarcodeGen.PhaseRandomization.generate_rand_barcodes_from_fft_zero_model(interpData,seqNum);
            
            halfL = floor(lengthOfSequences/2);
            
            for i=1:numberOfSequences
                PR1 = exp(2i*pi*rand(1,halfL));
                PR2 = fliplr(conj(PR1));

                if mod(lengthOfSequences,2)==0
                    PR = [1 PR1(1:end-1) 1 PR2(2:end)];
                else
                     PR = [1 PR1 PR2];
                end
                
                randomSequences{i} = ifft((interpData.*PR).*conj(fft((ker))));
            end
            
            return;
            
        case 'stationary'
            
             corrEst = ifft(inputData)-mean(ifft(inputData));
             corrEstNorm = corrEst/corrEst(1);
            
             t = 0:length(corrEstNorm(1:end/2))-1;
             
             f = @(y) sum((corrEstNorm((1:end/2))-exp(-t.^2./y.^2)).*exp(-t.^2./y.^2).*t.^2/y.^3);
                    
             x0 = 5.1; % note: make initial choice estimate automatic
             l = fsolve(f, x0, optimoptions('fsolve', 'Display','off'));
            % l
             t=0:lengthOfSequences/2;
             autoCorr = exp(-(t./l).^2);
            
             sHatSqrt = Zeromodel.compute_circulant_matrix( autoCorr, 'linear' );
   
             randomSequences = Zeromodel.compute_circulant_matrix_barcodes( sHatSqrt, lengthOfSequences,numberOfSequences, ker,  'circular' );
           
		case 'random'
            % in case completely random model is selected, just draw seqLen
            % numbers from normrnd seqNum times
			randomSequences = cell(1,numberOfSequences);
			for i=1:numberOfSequences
				randomSequences{i} = normrnd(0,1,1,lengthOfSequences);
			end
			return;
            
        otherwise
            randomSequences = [];
            warning('Unexpected choice of randomisation method')
            return;
    end
     
end

