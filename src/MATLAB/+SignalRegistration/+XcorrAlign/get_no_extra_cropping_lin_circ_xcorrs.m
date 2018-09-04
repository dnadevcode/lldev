function [xcorrs, coverageLens, firstOffset] = get_no_extra_cropping_lin_circ_xcorrs(linSeq, circSeq, linSeqBitmask, circSeqBitmask)
    % get_no_extra_cropping_lin_circ_xcorrs
    %  Computes the normalized cross-correlation for a linear
    %   sequence and a circular sequence, flipped/not flipped,
    %   at different circular shifts and offsets, however
    %   offsets which would lead to cropping the linear sequence
    %   to a length shorter than the circular sequence's length
    %   are given xcorrs and coverageLens of zero (effectively
    %   allowing the values to be ignored by later functions)
    % Inputs:
    %  linSeq & circSeq - the non-periodic and periodic sequence
    %    we wish to align
    %  linSeqBitmask & circSeqBitmask - bitmasks for the
    %   two sequences
    %   (linSeqBitmask & circSeqBitmask are aligned based only on
    %     the values and positions of the true bits in the bitmask
    %     corresponding to the data in the sequences)
    %
    % Outputs:
    %  xcorrs - raw Pearson cross-correlation coefficient
    %    values as computed in a three-dimensional array.
    %    The first dimensions specifies whether a sequence was
    %     flipped (index 2 if true, 1 if false).
    %    The second dimension specifies how much circular
    %      shifting there was (index 1 = no shift, 2 = shift of 1,
    %    etc.)
    %    The third dimension specifies the linear offset,
    %      (index k => firstOffset + k linear shifting)
    %  coverageLens - Effective sample sizes corresponding to each
    %    xcorrs value

    linSeq = linSeq(:)';
    circSeq = circSeq(:)';
    if nargin < 3
        linSeqBitmask = true(size(linSeq));
    end
    if nargin < 4
        circSeqBitmask = true(size(circSeq));
    end
    linSeqBitmask = linSeqBitmask(:)';
    circSeqBitmask = circSeqBitmask(:)';
    linSeqLen = length(linSeq);
    circSeqLen = length(circSeq);
    if linSeqLen <= circSeqLen
        import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
        [xcorrs, coverageLens, firstOffset] = get_no_crop_lin_circ_xcorrs(linSeq, circSeq, linSeqBitmask, circSeqBitmask);
        return;
    end
    import SignalRegistration.XcorrAlign.get_lin_circ_xcorrs;
    [xcorrs, coverageLens, firstOffset] = get_lin_circ_xcorrs(linSeq, circSeq, linSeqBitmask, circSeqBitmask, circSeqLen - linSeqLen, 0);
end