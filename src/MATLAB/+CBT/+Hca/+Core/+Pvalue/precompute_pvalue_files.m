function [] = precompute_pvalue_files(fullPath, params )
    % precompute_pvalue_files
    
    % compute the psf
    psf = params.psfSigmaWidth_nm/params.pixelWidth_nm;
    
    % compute the long random barcode
    rand2 = normrnd(0,1, 1, params.len2);
    import CBT.Hca.Core.Pvalue.convolve_bar;
    rand2 = convolve_bar(rand2, psf, length(rand2));

    % number of random barcodes
    % numRnd = 1000;
    
    % the short lengths that we need to compute for
    import CBT.Hca.Core.Pvalue.compute_random_max_cc;

    lens =params.lenMin:params.lenMax;
    
    % store the results in data
    %data = cell(1,length(lens));
    for i =1:length(lens)
        import CBT.Hca.Import.load_pval_struct;
        [ vals, data ] = load_pval_struct(fullPath);
        lenCur = lens(i);
        disp(strcat(['Computing p-value for barcodes of length ' num2str(lenCur) ', already done ' num2str(i-1) ' out of ' num2str(length(lens))]));
        [dataNew] = compute_random_max_cc(lenCur,rand2, psf, params.numRnd);%%    
%         
        [a,b] = ismember(lenCur, vals);
        if a~=0 
            data{b} =[data{b}; dataNew'];
        else
            vals(end+1) = lenCur;
            data{end+1} = dataNew';
        end
        import CBT.Hca.Export.export_pval_struct;
        export_pval_struct( fullPath,vals,data );
    end
end

