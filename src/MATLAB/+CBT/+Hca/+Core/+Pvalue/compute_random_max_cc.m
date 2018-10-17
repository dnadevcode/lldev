function [data] = compute_random_max_cc(len1,rand2,psf, numRnd)

    % Computes maximum correlation for a given number of random barcodes
    bit1 = ones(1,len1);
    bit2 = ones(1,length(rand2));
    
    data = zeros(1,numRnd);
    import CBT.Hca.Core.Pvalue.convolve_bar;

    for i =1:numRnd
        rand1 = normrnd(0,1, 1, len1);
        rand1 = convolve_bar(rand1, psf, len1 );
        [ccM] = CA.CombAuc.Core.Comparison.get_cc_fft(rand1, rand2, bit1,bit2);
        data(i) = max(ccM(:));
    end
    
end

