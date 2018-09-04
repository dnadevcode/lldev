function [] = plot_gumbel_hist(hAxis, maxPCCsWithRandBarcodes, gumbelCurveMu, gumbelCurveBeta)

    ccHistEdges = linspace(-1,1,101);

    % Generate PDFs
    z = (ccHistEdges - gumbelCurveMu) / gumbelCurveBeta;
    gumbel = 1 / gumbelCurveBeta * exp(-(z + exp(-z)));
    ccExHist = histc(maxPCCsWithRandBarcodes, ccHistEdges);
    ccExHist = ccExHist / ((ccHistEdges(2) - ccHistEdges(1)) * sum(ccExHist));

    % Calculate R^2
    SSTot = sum((ccExHist - mean(ccExHist)).^2);
    SSres = sum((ccExHist - gumbel).^2);
    R = 1 - (SSres/SSTot);

    plot(hAxis, ccHistEdges, ccExHist, ccHistEdges, gumbel);
    ylabel(hAxis, 'PDF');
    xlabel(hAxis, 'CC');
    legend(hAxis, {'CC hist', 'Gumbel'});
    titleStr = sprintf('Gumbel, mu = %g, gumbelCurveBeta = %g, R = %g', gumbelCurveMu, gumbelCurveBeta, R);
    title(hAxis, titleStr);
end