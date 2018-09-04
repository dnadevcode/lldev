function [matOut] = shift_align_2d_mat_rows(matIn, shiftOffsets, padval)
    padding = [0, max(abs(shiftOffsets))];
    matOut = padarray(matIn, padding, padval);
    shiftOffsets(shiftOffsets > 0) = floor(shiftOffsets(shiftOffsets > 0));
    shiftOffsets(shiftOffsets < 0) = ceil(shiftOffsets(shiftOffsets < 0));
    numRows = size(matOut, 1);
    for rowNum=1:numRows
        matOut(rowNum,:) = circshift(matOut(rowNum,:), shiftOffsets(rowNum), 2);
    end
end