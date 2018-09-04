function [centerOfMass] = compute_center_of_mass(rawKymoBgZeroed)
    [numRows, numCols] = size(rawKymoBgZeroed);
    centerOfMass = zeros(numRows, 1);
    pixelColIdxs = 1:numCols;
    for rowNum = 1:numRows
        singleKymoFrame = rawKymoBgZeroed(rowNum, :);
        centerOfMass(rowNum)= sum(pixelColIdxs.*singleKymoFrame)/sum(singleKymoFrame);
    end
end