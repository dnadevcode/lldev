function [ dot_barcode ] = generate_barcode_from_dot_positions(dotPositions,dotWidths,barcode_range)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    if nargin < 3 || isempty(barcode_range)
        barcode_range = dotPositions(1):0.1:dotPositions(end);
    elseif length(barcode_range) == 2
        barcode_range = barcode_range(1):0.1:barcode_range(end);
    end
    
%     x = barcode_range(1):barcode_range(2):barcode_range(end);
    gaussianArray = zeros(length(barcode_range),length(dotPositions));
    
    if length(dotWidths) == 1
        dotWidths = repmat(dotWidths,length(dotPositions),1);
    end
    
    for dot = 1:length(dotPositions)
        gaussianArray(:,dot) = exp(-(barcode_range-dotPositions(dot)).^2/(2*dotWidths(dot).^2));
    end

    dot_barcode = max(gaussianArray,[],2);
end

