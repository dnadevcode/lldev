function [hitCcDistParams] = hit_ev_params(barcodeQuery, targetLen, hits, randBarcodeFunction)
    % A function to find probability distribution parameters for hits from HMMSEARCH
    %   barcodeQuery: The query barcode sequence (Same as profile(?))
    %   hits: A table of hits between the query and target sequence. Each row should have
    %       the following format: query_start, query_end, target_start, target_end.
    %   randBarcodeFunction: a handle to a function that returns a cell array of random
    %       barcodes, with the following inputs: (lengthOfBarcodes, numberOfBarcodes).

    numRand = 1000;
    queryLen = length(barcodeQuery);
    targetMask = true(targetLen, 1);

    randBarcodes = randBarcodeFunction(targetLen, numRand);
    
    hitCcDistParams{size(hits, 1)} = [];

    for hitIdx = 1:size(hits, 1)
        queryMask = false(queryLen, 1);
        queryMask(hits(hitIdx, 1):hits(hitIdx, 2)) = 1;
        bestCCs(numRand) = 0;
        for i = 1:length(randBarcodes)
            [xcorrs, ~, ~] = SignalRegistration.XcorrAlign.get_no_extra_cropping_lin_circ_xcorrs(barcodeQuery, randBarcodes{i}, queryMask, targetMask);
            bestCCs(i) = max(xcorrs(~isnan(xcorrs)));
        end
        hitCcDistParams{hitIdx} = evfit(-bestCCs);
    end
end
