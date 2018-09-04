function [trimmedContigBarcodes] = trim_contig_barcodes(contigBarcodes, numPixelsTrimmed)
    numContigs = length(contigBarcodes);
    trimmedContigBarcodes = cell(size(contigBarcodes));
    for contigNum = 1:numContigs
        contigBarcode = contigBarcodes{contigNum};
        startIdx = min(numPixelsTrimmed + 1, endIdx);
        endIdx = length(contigBarcode) - numPixelsTrimmed;
        if endIdx >= startIdx
            trimmedContigBarcodes{contigNum} = contigBarcode(startIdx:endIdx);
        else
            trimmedContigBarcodes{contigNum} = [];
        end
    end
end