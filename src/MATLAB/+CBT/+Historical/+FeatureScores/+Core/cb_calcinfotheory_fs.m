function [featureScore] = cb_calcinfotheory_fs(curve, minValDistBetweenAdjExtrema, smoothingWindowSz)
    % CB_CALCINFOTHEORY_FS = feature score for competitive binding theory barcodes
    %
    % Inputs: 
    %  curve
    %     the input barcode
    %  minValDistBetweenAdjExtrema
    %     the minimal distance between adjacent detected extrema
    %  smoothingWindowSz (optional; defaults to 1 - i.e. no smoothing)
    %     window size for how much to smooth the curve in preprocessing
    %
    % Outputs: 
    %   featureScore
    %     the feature score
    %
    % Authors:
    %   Erik Lagerstedt
    %   Saair Quaderi

    % SQ: Not sure this smoothing parameter/code is even worth
    %  keeping
    if nargin < 3
        % % historically smoothing was set to 5 but it's not
        % %  clear why it should happen, so commenting out
        % %  and setting to 1 so there is no smoothing by default
        % smoothingWindowSz = 5; 
        smoothingWindowSz = 1;
    end
    % Smooth the curve
    if smoothingWindowSz > 1
        curve = smooth(curve, smoothingWindowSz);
    end


    % Reisner rescale the barcode
    zscaledCurve = zscore(curve);

    import CBT.Historical.FeatureScores.Core.detect_local_extrema;
    [localExtremaIdxs, ~] = detect_local_extrema(curve, minValDistBetweenAdjExtrema);
    numExtrema = numel(localExtremaIdxs);

    if numExtrema > 1
        rescaledLocalExtremaVals = zscaledCurve(localExtremaIdxs);
        featureScore = sum(diff([rescaledLocalExtremaVals(:)', rescaledLocalExtremaVals(1)]).^2);
    else
        featureScore = 0;
    end
end