function [worstDiscrepencyMagnitudeNoFft, worstDiscrepencyMagnitudeFft] = lin_circ_consistency_check(a, b, aBitmask, bBitmask)
    % Compute things using the various approaches to see the degree
    % of discrepancy between the methods for the inputs
    import SignalRegistration.Xcorr.slow_comparable_xcorr_circ;
    import SignalRegistration.Xcorr.masked_norm_xcorr;

    validateattributes(a, {'numeric', 'logical'}, {'column', 'nonempty', 'real', 'finite', 'nonnan'});
    validateattributes(b, {'numeric', 'logical'}, {'column', 'nonempty', 'real', 'finite', 'nonnan'});
    validateattributes(aBitmask, {'logical', 'numeric'}, {'vector', 'binary'});
    validateattributes(bBitmask, {'logical', 'numeric'}, {'vector', 'binary'});

    [cc0, lags0] = slow_comparable_xcorr_circ(a, b, aBitmask, bBitmask);
    [cc1, lags1] = masked_norm_xcorr(a, b, aBitmask, bBitmask, false, true, max([length(a), length(b)]) - 1, true); %no fast fourier
    [cc2, lags2] = masked_norm_xcorr(a, b, aBitmask, bBitmask, false, true); %allow fast fourier
    if not(isequal(lags1, lags0))
        disp('slow_comparable_xcorr_circ');
        disp(lags0);
        disp('fft-free masked_norm_xcorr');
        disp(lags1);
        error('unequal lags');
    end
    if not(isequal(lags2, lags0))
        disp('slow_comparable_xcorr_circ');
        disp(lags0);
        disp('masked_norm_xcorr');
        disp(lags1);
        error('unequal lags');
    end
    worstDiscrepencyMagnitudeNoFft = max(abs(cc0 - cc1));
    worstDiscrepencyMagnitudeFft = max(abs(cc0 - cc2));
end
