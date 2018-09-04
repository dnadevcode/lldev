function [bestCC, flip, shiftShortVsLong, cut] = ccorr_circcirc(B1,B2)
    %  CCORR_CIRCCIRC calculates the cross correlation between two barcodes,
    %  where both barcodes are assumed to be circular ('circ').
    %
    % The shortest barcode ('short') is cut at a certain position ('cut'), and 
    % circularly permutated. Then short is "slided" across the longest code
    % ('long') and for every shift, the cross-correlation value is 
    % obtained in two ways: using the mirror ('ccb') 
    % and the non-mirror ('ccf') image of 'shortc'.
    % 
    % This process is done for every possible cut in 'short'.
    %
    % ccf/ccb = matrix with the cross correlation value for every shift 
    % and for every cut in 'short', in "forward"/"backward(mirror)"
    %
    % The cross correlation 'cc' will be the maximum value in both ccf and ccb.
    %
    % Resiner-rescaling is used: the parts of the barcodes being compared 
    % are rescaled to have mean = 0 and standard deviation = 1.
    % 
    % Inputs:   barcodes B1, B2 
    %           shortest/longest of B1 and B2 will be called 'short'/'long'
    %           if B1, B2 same length, B1='short', B2='long'
    % 
    % Outputs:  bestCC = best cross correlation value
    %           flip = orientation of 'short': mirror(flip=1), non-mirror(flip=0)   
    %           shiftShortVsLong' = shift of 'short' w r t 'long'   %           
    %           cut = position of cut in 'short'
    %           NOTE: 'shiftShortVsLong' is differently defined from 'shift'
    %                  in function CA.Old.Core.ccorr_lincirc
    % 
    % Authors: (2015)
    %   Paola Torche
    %   Erik Lagerstedt
    %   Tobias Ambj�rnsson
    %
    % TO DO: if barcodes are of the same length then replace 
    % "for i=1:L" 
    % by "for i=1:iMax with iMax=1 or L"  

    % Convert B1 and B2 to column vectors
    B1 = B1(:)'; 
    B2 = B2(:)';

    % Some preprocessing
    if length(B1)<=length(B2)
        short=B1;
        long=B2;
    else
        short=B2;
        long=B1;
    end
    S=length(short); L=length(long); 
    long_crop = zeros(1,S); 
    ccfbestcut = zeros(1,L);
    ccbbestcut = zeros(1,L);
    bestcutf = zeros(1,L);
    bestcutb = zeros(1,L);

    short = zscore(short);     % reisner-rescale

    % Mu and Sigma calculation
    for i=1:L     % cut out barcode from 'long' starting at position i

        if i+S > L
            long_crop(1:L-i+1) = long(i:end);
            long_crop(L-i+2:end) = long(1:S-end+i-1);
        else
            long_crop = long(i:S+i-1);
        end
        long_crop = zscore(long_crop);    % reisner-rescale

        % Use FFT to evaluate the cross correlation
        conj_fft_longcrop = conj(fft(long_crop));
        ccf = ifft(fft(short).*conj_fft_longcrop); 
        ccb = ifft(fft(fliplr(short)).*conj_fft_longcrop);
        % "clean up" backward vector
        ccb = circshift(ccb,[0,-1]); 
        ccb = fliplr(ccb);

        % find the best cut for a given position i   
        [ccfbestcut(i),bestcutf(i)] = max(ccf);
        [ccbbestcut(i),bestcutb(i)] = max(ccb);
    end 

    % find the best position 
    [ccfbestposition,fbestposition] = max(ccfbestcut); 
    [ccbbestposition,bbestposition] = max(ccbbestcut);

    if ccbbestposition>ccfbestposition     % if "mirror" is best
        bestCC=ccbbestposition/(S-1); % normalize
        flip=1;
        position = bbestposition;
        cut=bestcutb(bbestposition);
    else                         % if "non-mirror" is best
        bestCC=ccfbestposition/(S-1); % normalize
        flip=0;
        position = fbestposition;
        cut=bestcutf(fbestposition);
    end

    shiftShortVsLong = position-1;
end