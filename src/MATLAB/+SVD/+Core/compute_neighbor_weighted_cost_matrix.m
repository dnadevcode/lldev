function costMat = compute_neighbor_weighted_cost_matrix(seq1, seq2, distance)
    %Computes the neighbor-weighted cost matrix for two barcodes.
    %Input: two barcodes (array of intensity values)and neighbour-
    %weighting distance. 
    %Output: cost matrix.

    % Note this wraps around at edge as if both are cyclical...
    % TODO: reconsider this vs alternatives!
    %    e.g. if warped barcode is noncyclical, exclude index
    %    overflow values and divide the costs by number of
    %    non-overflowing offsets available for normalization
    
    % Note from Saair: Rewrote this from three nested for loops
    %   to use convolution and cyclical padding to improve speed
    import SVD.Core.compute_abs_diff_cost_matrix;
    costMat = compute_abs_diff_cost_matrix(seq1, seq2);
    costMatPadded = conv2(padarray(costMat, [1, 1].*distance, 'circular', 'both'), eye(distance*2 + 1), 'same');
    costMat = costMatPadded((1:size(costMat, 1)) + distance, (1:size(costMat, 2)) + distance);
    costMat = repmat(costMat, [1, 2]);
end