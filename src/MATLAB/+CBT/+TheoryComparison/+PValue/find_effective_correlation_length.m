function [rI, r] = find_effective_correlation_length(cHatMean, mu, sigma, I)
    import CBT.TheoryComparison.PValue.ImportExport.get_f_rI;

    f_rI = get_f_rI(I);

    f_rI_targetVal = (cHatMean - mu)/sigma;
    [~, rI] = min(abs((f_rI_targetVal - f_rI)));
    r = rI/I;
end