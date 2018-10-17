function [data, len1] = precompute_pvalue_files_method_1(strFac, len1, len2, psfSigmaWidth_nm,pixelWidth_nm,numRnd )
    
    % compute the psf
    psf = psfSigmaWidth_nm/pixelWidth_nm;
    
    % compute the long random barcode
    rand2 = normrnd(0,1, 1, len2);
    import CBT.Hca.Core.Pvalue.convolve_bar;
    rand2 = convolve_bar(rand2, psf, length(rand2));

    % number of random barcodes
    % numRnd = 1000;
    
    % the short lengths that we need to compute for
    len1 = round(min(len1)*strFac(1)):1:round(max(len1)*strFac(end));
    import CBT.Hca.Core.Pvalue.compute_random_max_cc;

    % store the results in data
    data = cell(1,length(len1));
    for i =1:length(len1)
        disp(strcat(['Computing p-value for barcodes of length ' num2str(len1(i)) ', already done ' num2str(i-1) ' out of ' num2str(length(len1))]));
        [data{i}] = compute_random_max_cc(len1(i),rand2, psf, numRnd);%% 
    end
end

