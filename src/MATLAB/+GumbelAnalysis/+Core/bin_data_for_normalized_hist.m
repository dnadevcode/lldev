function [binCenters, numBinElems, binWidth] = bin_data_for_normalized_hist(values)
    numValues = length(values);
    numBins = round(sqrt(numValues));
    [numBinElems, binCenters] = hist(values, numBins);
    binWidth = binCenters(2) - binCenters(1);
end