function [ fitParams ] = barcode_ev_fit( barcode, randBarcodes )
%VITERBI_EV_PARAMS_WRAP Summary of this function goes here
%   Detailed explanation goes here
    
    vitDistParams{size(randBarcodes, 2)} = [];
    
    for i = 1:size(randBarcodes, 2)
        vitDistParams{i} = StructVar.Stats.viterbi_ev_params(barcode, randBarcodes(:, i));
    end
    lens = cellfun(@length, randBarcodes(1, :));
    fitParams{1} = polyfit(lens, cellfun(@(x) x(1), vitDistParams), 1);
    fitParams{2} = polyfit(lens, cellfun(@(x) x(2), vitDistParams), 2);
end

