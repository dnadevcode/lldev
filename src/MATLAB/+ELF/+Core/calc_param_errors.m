function [sigmaPeakPos, sigmaPeakArea] = calc_param_errors(barcodeRegionLen, peakPositionsVect, peakAreasVect, psfSigmaWidth_px, xStartIdx, xEndIdx, stdBackgroundNoise, areaOnePeak)
    % Calculated the errors in the parameters ('sigmaPos', 'sigmaAre') for this specific model
    % The errors are calculated from the variance-covariance matrix (stdNoise*sqrt(inv(hessian)))
    % the hessian is approximated to its first derivatives terms

    numPeaks = length(peakParams);
    xIdxs = (xStartIdx:xEndIdx)';
    firstDerivatives = zeros(2*numPeaks, barcodeRegionLen);
    minimGaussian = @(mu) areaOnePeak * gaussmf(xIdxs, [psfSigmaWidth_px, mu]) / (sqrt(2 * pi) * psfSigmaWidth_px);
    for peakIdx = 1:numPeaks
        firstDerivatives(peakIdx,:) = peakAreasVect(peakIdx)*minimGaussian(peakPositionsVect(peakIdx)) .* (xIdxs - peakPositionsVect(peakIdx)) / (psfSigmaWidth_px^2);
        firstDerivatives(peakIdx + numPeaks, :) = minimGaussian(peakPositionsVect(peakIdx));
    end
    firstDervTerm = firstDerivatives * firstDerivatives';
    hessian = 2 * firstDervTerm;
    errorsParam = abs(stdBackgroundNoise * sqrt(inv(hessian)));

    sigmaPeakPos = NaN(1, numPeaks);
    sigmaPeakArea = NaN(1, numPeaks);
    for peakIdx = 1:numPeaks
        sigmaPeakPos(peakIdx) = errorsParam(peakIdx, peakIdx) ;
        sigmaPeakArea(peakIdx) = errorsParam(peakIdx + numPeaks, peakIdx + numPeaks) ;
    end
end