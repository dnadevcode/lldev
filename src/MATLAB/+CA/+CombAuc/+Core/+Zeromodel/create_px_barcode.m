function [ barcodeBpRes,barcodePxRes] = create_px_barcode( plasmid, psfSigmaWidth, kbpPerPixel, method )
% 20/12/16
    if nargin < 3
        method = 'old';
    end
    
    switch method
        case 'old'
            import CA.Core.Cbt.cb_transfer_matrix2;
            [barcodeBP] = cb_transfer_matrix2(plasmid);
        case 'new'
            import CA.Core.Cbt.cb_transfer_matrix_editable;
            [barcodeBP] = cb_transfer_matrix_editable(plasmid);
    end
    
    import CA.Core.Zeromodel.gaussian_kernel;
    ker = gaussian_kernel(length(barcodeBP), psfSigmaWidth);

    barcodeBpRes= ifft(fft(barcodeBP).*conj(fft(transpose(ker)))); 

   % barcodePxRes = interp1([1:length(barcodeBpRes)], barcodeBpRes,linspace(1,length(barcodeBpRes),length(barcodeBpRes)/(settings.bpPerNm*settings.camRes )));

    % maybe want to be more careful how we interpolate.. here use matlab
    % standart interp1..
    barcodePxRes = interp1([1:length(barcodeBpRes)], barcodeBpRes,linspace(1,length(barcodeBpRes),length(barcodeBpRes)/(kbpPerPixel )));

end

