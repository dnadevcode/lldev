function [xcorrs, coverageLens, firstOffset] = get_lin_circ_xcorrs(linSeq, circSeq, linSeqBitmask, circSeqBitmask, offsetMin, offsetMax)
    % get_no_crop_lin_circ_xcorrs
    %  Computes the normalized cross-correlation for a linear
    %   sequence and a circular sequence, flipped/not flipped,
    %   at different circular shifts and offsets
    % Inputs:
    %  linSeq & circSeq - the non-periodic and periodic sequence
    %    we wish to align
    %  linSeqBitmask & circSeqBitmask - bitmasks for the
    %   two sequences
    %   (linSeqBitmask & circSeqBitmask are aligned based only on
    %     the values and positions of the true bits in the bitmask
    %     corresponding to the data in the sequences)
    %  offsetMin & offsetMax - restricts the range of offsets to
    %    get values with (an offset can result in cropping
    %    the linear sequence from one of the two ends before
    %    sliding it across the circular sequence at various
    %    circular shifts)
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
    %
    %  Note: This covers all cases where the length of the linear
    %    subsequence is less than or equal to the length of the 
    %    circular sequence
    import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;

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
    if nargin < 5
        offsetMin = 2 - linSeqLen;
    else
        offsetMin = max(2 - linSeqLen, offsetMin);
    end

    if nargin < 6
        offsetMax = linSeqLen - 2;
    else
        offsetMax = min(offsetMax, linSeqLen - 2);
    end

    maxOffsetMag = max(abs([offsetMin, offsetMax]));

    circSeqLen = length(circSeq);
    offsets = -maxOffsetMag:1:maxOffsetMag;
    xcorrs = zeros(2, circSeqLen, length(offsets));
    coverageLens = xcorrs;
    offsetIdx = 1;
    firstOffset = offsets(1);
    for offset = offsets
        if ((offset < offsetMin) || (offset > offsetMax))
            xcorrs(:, :, offsetIdx) = NaN;
            coverageLens(:, :, offsetIdx) = NaN;
            continue;
        end
        startIdx = offset + (linSeqLen - circSeqLen) + 1;
        endIdx = startIdx + (circSeqLen - 1);
        startIdx = max(startIdx, 1);
        endIdx = min(endIdx, linSeqLen);
        linSeqIndices = startIdx:endIdx;
        croppedLinSeq = linSeq(linSeqIndices);
        croppedLinSeqBitmask = linSeqBitmask(linSeqIndices);
        [xcorrsSlice, coverageLensSlice] = get_no_crop_lin_circ_xcorrs(croppedLinSeq, circSeq, croppedLinSeqBitmask, circSeqBitmask);
        xcorrs(:, :, offsetIdx) = xcorrsSlice;
        coverageLens(:, :, offsetIdx) = coverageLensSlice;
        offsetIdx = offsetIdx + 1;
    end
end
