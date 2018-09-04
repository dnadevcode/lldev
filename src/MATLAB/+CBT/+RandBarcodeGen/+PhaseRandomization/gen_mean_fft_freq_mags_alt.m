function [meanFftFreqMags] = gen_mean_fft_freq_mags_alt(zeroModelBarcodes)

%     import CBT.RandBarcodeGen.PhaseRandomization.gen_mean_fft_freq_mags;
%     meanFftFreqMags = gen_mean_fft_freq_mags(zeroModelBarcodes);
%     return;
                    
% TODO Note from Saair: I think this is outdated version and can be deleted
%   but leaving it here just in case for the moment
    % Generates a ZM fft from the ZM barcodes
    % This is only used within the main program since no
    %  kbp/pixel calculation is done

    % Find longest ZM barcode
    barcodeLens = cellfun(@length, zeroModelBarcodes);
    newFftLen = max(barcodeLens);
    
    newLenIsEven = (mod(newFftLen, 2) == 0);
    
    % Get the mean FT of the reference barcodes
    resizedBarcodeFftFreqMagsMat = zeros(length(zeroModelBarcodes), newFftLen);
    numBarcodes = length(zeroModelBarcodes);
    sharedInterpLen = floor(newFftLen/2);
    for barcodeNum = 1:numBarcodes
        currBarcode = zeroModelBarcodes{barcodeNum};
        oldFft = fft(currBarcode);
        
        oldFftFreqMags = abs(oldFft);
        oldFftLen = length(oldFftFreqMags);

        uptoHalfOldFftLen = floor(oldFftLen / 2);

        % Interpolate
        interpPts = linspace(1, uptoHalfOldFftLen, sharedInterpLen);
        oldFftFreqMagsShift = fftshift(oldFftFreqMags);
        oldFftFreqMagsShiftStretched = interp1(oldFftFreqMagsShift(1:uptoHalfOldFftLen), interpPts);
        
        if newLenIsEven
            resizedFftFreqMags = [oldFftFreqMagsShiftStretched oldFftFreqMagsShift(uptoHalfOldFftLen + 1) fliplr(oldFftFreqMagsShiftStretched(2:end))];
        else
            resizedFftFreqMags = [oldFftFreqMagsShiftStretched oldFftFreqMagsShift(uptoHalfOldFftLen + 1) fliplr(oldFftFreqMagsShiftStretched)];
        end
        normFactor = 1/sum(resizedFftFreqMags);
        resizedFftFreqMags = resizedFftFreqMags * normFactor;
        if any(isnan(resizedFftFreqMags))
            warning('NaN in fft');
            continue;
        end
        resizedBarcodeFftFreqMagsMat(barcodeNum, :) = resizedFftFreqMags;
    end
    meanFftFreqMags = ifftshift(sum(resizedBarcodeFftFreqMagsMat, 1));
end