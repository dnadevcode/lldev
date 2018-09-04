function [xcorrs, coverageLens, firstOffset] = get_lin_lin_xcorrs(linSeqA, linSeqB, bitmaskA, bitmaskB)
    % get_lin_lin_xcorrs
    %  Computes the normalized cross-correlation for two bitmasked
    %   linear sequences, flipped/not flipped, at different offsets
    % Inputs:
    %  linSeqA & linSeqB - the two non-periodic sequences we wish
    %    to align
    %  bitmaskA & bitmaskB - bitmasks for the two sequences
    %   (linSeqA & linSeqB are aligned based only on the values
    %     and positions of the true bits in the bitmask
    %     corresponding to the data in the sequences)
    %
    % Outputs:
    %  xcorrs - raw Pearson cross-correlation coefficient
    %    values as computed in a three-dimensional array.
    %    The first dimensions specifies whether a sequence was
    %     flipped (index 2 if true, 1 if false).
    %    The second dimension specifies how much circular
    %      shifting there was (index 1 = no shift, 2 = shift of 1,
    %    etc.), and is always 1 since there is no circular
    %      shifting involved with a pair of linear sequences
    %    The third dimension specifies the linear offset,
    %      (index k => firstOffset + k linear shifting)
    %  coverageLens - Effective sample sizes corresponding to each
    %    xcorrs value
    %   firstOffset gives the offset to be used to make sense of the
    %    indices for the third dimension of xcorrs
    import SignalRegistration.Xcorr.zero_extend_linear_seq;
    import SignalRegistration.XcorrAlign.norm_xcorr;

    linSeqA = linSeqA(:)';
    linSeqB = linSeqB(:)';

    if nargin < 3
        bitmaskA = true(size(linSeqA));
    end
    if nargin < 4
        bitmaskB = true(size(linSeqB));
    end
    bitmaskA = bitmaskA(:)';
    bitmaskB = bitmaskB(:)';
    lenA = length(linSeqA);
    lenB = length(linSeqB);
    if (lenA ~= lenB)
        maxLen = max(lenA, lenB);
        linSeqA = zero_extend_linear_seq(linSeqA', 0, maxLen - lenA)';
        linSeqB = zero_extend_linear_seq(linSeqB', 0, maxLen - lenB)';
        bitmaskA = zero_extend_linear_seq(bitmaskA', 0, maxLen - lenA)';
        bitmaskB = zero_extend_linear_seq(bitmaskB', 0, maxLen - lenB)';
    end
    [xcorrsReg, coverageLensReg, ~] = norm_xcorr(linSeqA, linSeqB, bitmaskB, bitmaskA, false, false);
    [xcorrsFlipped, coverageLensFlipped, ~] = norm_xcorr(fliplr(linSeqA), linSeqB, fliplr(bitmaskA), bitmaskB, false, false);

    xcorrs = permute([...
        xcorrsReg;...
        xcorrsFlipped...
    ], [1, 3, 2]);

    coverageLens = permute([...
        coverageLensReg;...
        coverageLensFlipped...
    ], [1, 3, 2]);

    firstOffset = 0 - (size(xcorrs, 3) - 1)/2;
end
