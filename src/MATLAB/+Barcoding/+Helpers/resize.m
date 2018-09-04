function [ outBar ] = resize( barcode, bpLen, bpPerPx)
%RESIZE Resizes an input barcode based on an input basepair length.
%   barcode:    Input barcode (double vector).
%   bpLen:      Length in basepairs
%   bpPerPx:    (optional) Number of basepairs per pixel

    if nargin < 3
        bpPerPx = 541;
    end

    dim = size(barcode);
    dim(dim > 1) = bpLen/bpPerPx;
    outBar = imresize(barcode, dim);

end

