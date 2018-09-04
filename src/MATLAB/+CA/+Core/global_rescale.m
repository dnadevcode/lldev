function [globalMean, globalStd, rescaledBarcodes] = global_rescale(barcodes)
    % Rescales all the contigs so that the mean is 0 and
    % standard deviation is 1 for all the values combined
    barcodes = cellfun(@(barcode) barcode(:)', barcodes, 'UniformOutput', false);
    aggregatedBarcodes = horzcat(barcodes{:});

    globalMean = nanmean(aggregatedBarcodes);
    globalStd = nanstd(aggregatedBarcodes);

    if nargout > 2
        rescaledBarcodes = cell(length(barcodes),1);
        for barcodeNum = 1:length(barcodes)
            rescaledBarcodes{barcodeNum} = (barcodes{barcodeNum}-globalMean)/globalStd;
        end
    end
end
