function [xcorrs, coverageLens, firstOffset] = get_circ_circ_xcorrs(circSeqA, circSeqB, circSeqBitmaskA, circSeqBitmaskB)
    % get_circ_circ_xcorrs
    %  Computes the normalized cross-correlation for two circular
    %   sequences, flipped/not flipped, at different circular
    %   shifts
    % Inputs:
    %  circSeqA & circSeqB - the two periodic sequences
    %    we wish to align
    %  circSeqBitmaskA & circSeqBitmaskB - bitmasks for the
    %   two sequences
    %   (circSeqA & circSeqB are aligned based only on
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
    %    The third dimension typically specifies the linear offset,
    %      (index k => firstOffset + k linear shifting), but 
    %      does not apply in this case
    %  coverageLens - Effective sample sizes corresponding to each
    %    xcorrs value
    %
    %  Note: This only covers all cases where the length of the linear
    %    subsequence is less than or equal to the length of the 
    %    circular sequence
    import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;

    circSeqA = circSeqA(:)';
    circSeqB = circSeqB(:)';
    lenA = length(circSeqA);
    lenB = length(circSeqB);
    if (lenA ~= lenB)
        error('Cross-correlation computation not supported for circular sequences of unequal lengths');
        %todo: stretching method parameter?
    end
    if nargin < 3
        circSeqBitmaskA = true(size(circSeqA));
    end
    if nargin < 4
        circSeqBitmaskB = true(size(circSeqB));
    end
    circSeqBitmaskA = circSeqBitmaskA(:)';
    circSeqBitmaskB = circSeqBitmaskB(:)';
    [xcorrs, coverageLens, firstOffset] = get_no_crop_lin_circ_xcorrs(circSeqA, circSeqB, circSeqBitmaskA, circSeqBitmaskB);

    % firstOffset should still always be zero since they are never
    %  necessary when both sequences are circular since the
    %  relative position is fully captured in circShift
    %  since both are the same length size(xcorrs, 3) = 1

end