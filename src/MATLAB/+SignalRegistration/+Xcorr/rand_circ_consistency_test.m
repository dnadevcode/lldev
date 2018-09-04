function [worstDiscrepencyMagnitudeNoFft, worstDiscrepencyMagnitudeFft, a, b, bitmaskA, bitmaskB] = rand_circ_consistency_test(circLen)
    % Runs a consistency check for a circle sequence of a given
    % length, a linear sequence of a random length which is no
    % greater than the circular sequence.
    % Bitmasks are randomly generated to be of the appropriate
    % lengths
    import SignalRegistration.Xcorr.lin_circ_consistency_check;

    a = rand(circLen, 1);
    noise = rand(circLen, 1)/10;
    delayed = randi([1, circLen]);
    b = circshift(a, delayed) + noise;
    croppedLenA = circLen - randi([1, circLen]);
    a = a(1:croppedLenA);
    bitmaskA = logical(randi([0, 1], size(a)));
    bitmaskB = logical(randi([0, 1], size(b)));
    [worstDiscrepencyMagnitudeNoFft, worstDiscrepencyMagnitudeFft] = lin_circ_consistency_check(a, b, bitmaskA, bitmaskB);
end