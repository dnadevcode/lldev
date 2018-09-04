function [ err ] = calculate_error(peakPositionsVect, areasVect, xIdxs, experimentalValues, psfSigmaWidth, areaOnePeakScaled, meanBackgroundNoise)
    % This is the function ('err') the non-linear least squares problem seeks to minimize
    % 'err' is the difference between the fit and the experiment
    % Inputs :
    %     - params vector (it first half contains the positions of the peaks, the second the areas)
    %     - xaxis
    %     - y (the barcode from the experiment )

     predictedValues = zeros(length(xIdxs), 1);
     for peakIdx = 1:length(peakPositionsVect)
         predictedValueOffset = areaOnePeakScaled * areasVect(peakIdx) * gaussmf(xIdxs, [psfSigmaWidth, peakPositionsVect(peakIdx)])' ;
         predictedValues = predictedValues + predictedValueOffset;
     end
     predictedValues = predictedValues / (sqrt(2 * pi) * psfSigmaWidth) + meanBackgroundNoise;
     err = predictedValues(:) - experimentalValues(:);
 end