function [ sequenceBarcodes, probNums ] = sequence_barcodes( sequences, settings, isLinear )

    if nargin < 3
        isLinear = false;
    end
    

    import CA.CombAuc.Core.Zeromodel.get_binding_probs;
    [bindingProbabilities, probNums] = get_binding_probs(sequences, settings.shortestSeq, settings.concYOYO1_molar,settings.YOYO1conc);
    
    import CA.CombAuc.Core.Zeromodel.gaussian_kernel;

    %figure,plot(bindingProbabilities{1})
    sequenceBarcodes = cell(1,length(bindingProbabilities));
    for iInd=1:length(bindingProbabilities)
        if isLinear
            bindProb = [bindingProbabilities{iInd}; mean(bindingProbabilities{iInd})*ones(round(3*settings.psfSigmaWidth),1)]; 
        else
            bindProb = bindingProbabilities{iInd};
        end
        ker = gaussian_kernel(length(bindProb),settings.psfSigmaWidth);
        sequenceBarcodes{iInd}= ifft(fft(bindProb).*conj(fft(transpose(ker)))); 
        
        if isLinear
            sequenceBarcodes{iInd} = sequenceBarcodes{iInd}(1:length(bindingProbabilities{iInd}));
        else
    end


end


