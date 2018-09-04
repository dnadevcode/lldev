function [ discrete_barcode ] = discretize_barcode( zscaled_barcode )
%DISCRETISE_BARCODE Discretises a zscaled barcode (list of pixel intensities)
%   The discrete barcode is a list of ints, ranging from 1 to 60
%   generated from a zscaled input.
%   Can only contain -10:10, although assuming normal distribution this should include
%   pretty much everything.
    discrete_barcode = round((zscaled_barcode + 10) * 3);
    discrete_barcode(discrete_barcode < 1) = ones(1, sum(discrete_barcode < 1));
    discrete_barcode(discrete_barcode > 60) = repmat(60, 1, sum(discrete_barcode > 60));
    discrete_barcode = discrete_barcode(:)';
end

