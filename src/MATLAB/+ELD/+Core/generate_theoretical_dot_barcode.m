function [ theoretical_dot_barcode ] = generate_theoretical_dot_barcode(theoreticalSequence,targetSequence,dotWidths,barcodeLength,molecule_ends)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%     theoretical_dot_barcode = zeros(round(barcodeLength),1);

    import dotkymoAlignment.*

    if nargin < 5 || isempty(molecule_ends)
        molecule_ends = 0;
    end
    
    targetLength = length(targetSequence);
    targetIdxs = strfind(theoreticalSequence,targetSequence);
    dotPositions = targetIdxs + targetLength/2.0 - 1;
    
    
    if molecule_ends == 1
        molecule_ends = [dotPositions(1), dotPositions(end)];
    end

    
    if length(dotWidths) == 1
        dotWidths = repmat(dotWidths,length(dotPositions),1);
    end
    
    theoretical_dot_barcode = generate_barcode_from_dot_positions(dotPositions,dotWidths,barcodeLength,molecule_ends);
    
end

