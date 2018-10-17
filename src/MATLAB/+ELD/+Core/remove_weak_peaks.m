function [ output_bitmask ] = remove_weak_peaks( kymograph, input_bitmask )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    kymograph = kymograph/(max(kymograph(:)));

    thresholdVal = graythresh(kymograph);
    threshImg = kymograph >= thresholdVal/2;
    
%     threshImg = imbinarize(kymograph);
    
    output_bitmask = threshImg.*input_bitmask;
% 
%     figure, imagesc(kymograph);
%     figure, imagesc(input_bitmask);
%     figure, imagesc(output_bitmask);
    
end

