function [rawKymoBgZeroed] = zeroify_raw_kymo_bg(rawKymo, rawKymoFgMask, meanBgLevel)
    rawKymoBgZeroed = rawKymo - meanBgLevel;
    rawKymoBgZeroed(~rawKymoFgMask) = 0;
    rawKymoBgZeroed(rawKymoBgZeroed<0) = 0;
end