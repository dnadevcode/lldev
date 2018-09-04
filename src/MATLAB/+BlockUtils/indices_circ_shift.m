function [circShiftedIndices] = indices_circ_shift(maxIndex, indices, shift)
    indices = indices(:);
    shift = mod(shift, maxIndex);
    circShiftedIndices = indices + shift;
    ii = find(circShiftedIndices > maxIndex, 1, 'first');
    if isempty(ii)
        return;
    end
    circShiftedIndices = [mod(circShiftedIndices(ii:end) - 1, maxIndex) + 1; circShiftedIndices(1:(ii - 1))];
end
