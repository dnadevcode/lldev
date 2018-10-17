function [ dotPositions , stretchFactor , molecule_ends] = calculate_shifted_dot_positions_with_margins(dotPositions,barcodeLength,molecule_ends,use_ends_for_stretching)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    endDotDistance = dotPositions(end)-dotPositions(1);

    if nargin < 2 || isempty(barcodeLength)
        if ~(nargin < 3 || isempty(molecule_ends))
            barcodeLength = ceil((molecule_ends(2) - molecule_ends(1)) / 0.9);
        else
            barcodeLength = ceil((endDotDistance) / 0.9);
        end
    else
        barcodeLength = ceil(barcodeLength);
    end
    
    if nargin < 3 || isempty(molecule_ends)
        molecule_ends = 0;
    end
    
    if nargin < 4 || isempty(use_ends_for_stretching) || isempty(molecule_ends)
        use_ends_for_stretching = false;
    end
    
    targetLength = 0.9 * barcodeLength;
    
    if use_ends_for_stretching
        stretchFactor = targetLength / (molecule_ends(2) - molecule_ends(1));
    else
        stretchFactor = targetLength / endDotDistance;
    end
    
    if molecule_ends(end)~=0
        molecule_ends(2) = barcodeLength * 0.05 + (molecule_ends(2) - dotPositions(1)) * stretchFactor;
        molecule_ends(1) = barcodeLength * 0.05 - (dotPositions(1) - molecule_ends(1)) * stretchFactor;
    end
    
    dotPositions = dotPositions - dotPositions(1);
    
    dotPositions = dotPositions * stretchFactor;
    dotPositions = dotPositions + barcodeLength * 0.05;
    
end