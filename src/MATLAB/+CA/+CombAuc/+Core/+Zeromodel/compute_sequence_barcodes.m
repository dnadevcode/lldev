function [ theoryCurveUnscaled_pxRes,bitmasks,theoryProb_bpRes ] = compute_sequence_barcodes( sequences, settings, isLinear )

    if nargin < 3
        isLinear = false;
    end
    
    import CBT.Core.cb_netropsin_vs_yoyo1_plasmid;
    concNetropsin_molar = settings.concNetropsin_molar;
    concYOYO1_molar = settings.concYOYO1_molar;
    psfSigmaWidth_bps = settings.psfSigmaWidth_nm / settings.meanBpExt_nm;
   
    import CBT.Core.convert_bpRes_to_pxRes;
    meanBpExt_pixels = settings.meanBpExt_nm / settings.pixelWidth_nm;

    theoryProb_bpRes = cell(1,size(sequences,1));
    for i=1:size(sequences,1)
        i
        probsBinding = cb_netropsin_vs_yoyo1_plasmid(sequences(i).Sequence, concNetropsin_molar,  concYOYO1_molar);
        theoryProb_bpRes{i} = probsBinding.Yoyo1;
    end
        
%     import CA.CombAuc.Core.Zeromodel.get_binding_probs;
%     [bindingProbabilities, probNums] = get_binding_probs(sequences, settings.shortestSeq, settings.concYOYO1_molar,settings.YOYO1conc);
    
    import CA.CombAuc.Core.Zeromodel.gaussian_kernel;

    %figure,plot(bindingProbabilities{1})
    theoryCurveUnscaled_pxRes = cell(1,length(theoryProb_bpRes));
    bitmasks = cell(1,length(theoryProb_bpRes));

    for iInd=1:length(theoryProb_bpRes)
        if isLinear
            bindProb = [theoryProb_bpRes{iInd} mean(theoryProb_bpRes{iInd})*ones(1,round(3*psfSigmaWidth_bps))]; 
        else
            bindProb = theoryProb_bpRes{iInd};
        end
        ker = gaussian_kernel(length(bindProb),psfSigmaWidth_bps);
        tempBar= ifft(fft(bindProb).*conj(fft(ker))); 
        
        if isLinear
            tempBar = tempBar(1:length(theoryProb_bpRes{iInd}));
        end
        
        if size(tempBar,2)/(1/meanBpExt_pixels) < 2 % if less than 2 pixels, just take the mean.
            theoryCurveUnscaled_pxRes{iInd} = mean(tempBar);
        else
            theoryCurveUnscaled_pxRes{iInd} =convert_bpRes_to_pxRes(tempBar,meanBpExt_pixels);
        end
        % adjust if there is untrusted region.. TODO
        bitmasks{iInd}  = ones(1,length(theoryCurveUnscaled_pxRes{iInd}));
    end

end


