function [circSeqOut, flipTF, circShift] = apply_rand_flip_and_shift(circSeqIn)
    %note: flipTF, circShift contain the values necessary to
    %    unshuffle the output sequence to the input sequence
    circSeqOut = circSeqIn;
    flipTF = logical(randi([0, 1]));
    if isempty(circSeqIn)
        circShift = 0;
        return;
    end
    validateattributes(circSeqIn, {'numeric'}, {'vector'}, 1);
    [len, lenDim] = max(size(circSeqIn));
    circShift = randi([1, len]) - 1;
    circSeqOut = circshift(circSeqOut, circShift, lenDim);
    if flipTF
        circSeqOut = flip(circSeqOut, lenDim);
    else
        circShift = mod(-circShift, len);
    end
    circSeqOut = reshape(circSeqOut, size(circSeqIn));
end