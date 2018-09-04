function [ vitDistParams ] = viterbi_ev_params( barcodeQuery, randBarcodes )
%VITERBI_EV_PARAMS Summary of this function goes here
%   Detailed explanation goes here
    numRand = 1000;
    queryLen = length(barcodeQuery);

    %randBarcodes = randBarcodeFunction(targetLen, numRand);
    [~, scores] = StructVar.hmmsearch({barcodeQuery}, randBarcodes);
    vitDistParams = evfit(-[scores{:}]);

end
