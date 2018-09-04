function [] = display_anaysis_text(alpha, thresholdBestCC, pValues, bestCCValues, useRecursiveApproachToGumbelFitting)
    format long;

    [pValuesSorted, pValueSortOrder] = sort(pValues);
    % pValueUpperErrorSorted = pValueUpperError(pValueSortOrder);
    % pValueLowerErrorSorted = pValueLowerError(pValueSortOrder);

    fprintf('alpha = %g\n', alpha);
    if useRecursiveApproachToGumbelFitting
        fprintf('Using recursive approach (excluding outliers from gumbel fitting recursively)\n');
    else
        fprintf('Using non-recursive approach (including outliers in gumbel fitting)\n');
    end
    fprintf('Match threshold of Best CC (with alpha) = %g\n', thresholdBestCC);

    numMatches = sum(pValues < alpha);
    fprintf(' \n');
    fprintf('Number of matches with alpha: %d\n', numMatches);
    for matchNum=1:numMatches
        barcodeNumber = pValueSortOrder(matchNum);
        ccValue = bestCCValues(barcodeNumber);
        pValue = pValuesSorted(matchNum);
        outlierScorePercentage = 100 * pValue;
        fprintf('  Barcode #%d: Best CC = %g; Outlier Score = %g%%\n', barcodeNumber, ccValue, outlierScorePercentage);
    end;
    fprintf(' \n');
end