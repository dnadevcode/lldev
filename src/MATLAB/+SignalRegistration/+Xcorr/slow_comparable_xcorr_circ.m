function [xcorrs, delays] = slow_comparable_xcorr_circ(a, b, aBitmask, bBitmask, delay)
    import SignalRegistration.Xcorr.zero_extend_linear_seq;
    import SignalRegistration.Xcorr.masked_rr_norm;

    validateattributes(a, {'numeric', 'logical'}, {'column', 'nonempty', 'real', 'finite', 'nonnan'});
    validateattributes(b, {'numeric', 'logical'}, {'column', 'nonempty', 'real', 'finite', 'nonnan'});
    validateattributes(aBitmask, {'logical', 'numeric'}, {'vector', 'binary'});
    validateattributes(bBitmask, {'logical', 'numeric'}, {'vector', 'binary'});

    % This is slow and is just meant for testing purposes
    %   as a "gold standard"
    a = zscore(a(:));
    b = zscore(b(:));

    aLen = length(a);
    bLen = length(b);
    maxLen = max(aLen, bLen);
    if (aLen < maxLen)
        a = zero_extend_linear_seq(a, 0, maxLen - aLen);
        aBitmask = zero_extend_linear_seq(aBitmask, 0, maxLen - aLen);
    end
    if (bLen < maxLen)
        error('b must not be shorter than a');
    end

    if nargin < 5
        delay = maxLen - 1;
    else
        delay = abs(delay);
    end
    idx = 1;
    delays = (-1*delay):1:delay;
    xcorrs = zeros(length(delays), 1);
    for delay=delays
        delayBBitmask = circshift(bBitmask, delay, 1);
        bitmask = aBitmask & delayBBitmask;
        sampleSize = sum(bitmask);
        if (sampleSize > 0)
            xcorrs(idx) = xcorr(masked_rr_norm(a, bitmask, true), masked_rr_norm(circshift(b, delay, 1), bitmask, true), 0);
            if (xcorrs(idx) ~= 0)
                xcorrs(idx) = xcorrs(idx)/(sampleSize - 1);
            end
        end
        idx=idx+1;
    end
end