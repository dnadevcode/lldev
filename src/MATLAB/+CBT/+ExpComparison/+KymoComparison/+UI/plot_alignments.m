function [] = plot_alignments(hAxis, consensusName, consensusBarcode, consensusBitmask, kymoNames, kymoBarcodes, kymoBitmasks)
    legendStrs = [{consensusName}; kymoNames(:)];
    numKymos = length(kymoBarcodes);
    consensusBarcode(not(consensusBitmask)) = NaN;
    hPlots = gobjects(numKymos + 1, 1);
    hPlots(1) = plot(hAxis, consensusBarcode, '-');
    hold(hAxis, 'on');
    for idx=1:numKymos
        tmpBarcode = kymoBarcodes{idx};
        tmpBitmask = kymoBitmasks{idx};
        tmpBarcode(not(tmpBitmask)) = NaN;
        hPlots(1 + idx) = plot(hAxis, tmpBarcode, '-.');
    end
    legend(hPlots, legendStrs{:});
end