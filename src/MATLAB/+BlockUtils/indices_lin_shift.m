function [linShiftedIndices] = indices_lin_shift(maxIndex, indices, shift)
    indices = indices(:);
    linShiftedIndices = indices + shift;
    linShiftedIndices = linShiftedIndices(linShiftedIndices > 0);
    linShiftedIndices = linShiftedIndices(linShiftedIndices <= maxIndex);
end
