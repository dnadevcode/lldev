function [aIndicesAtBestN, bIndicesAtBestN] = compute_alignment_params(...
            lenA, lenB, circularA, circularB,...
            flipAtBestN, circShiftAtBestN, offsetAtBestN)

    % compute_alignment_params
    %  Process and break down flipping/circshifting/offsetting
    %   inputs to per-sequence alignment outputs
    %   based on sequence lengths and circularity
    % Inputs:
    %  lenA & lenB - the lengths of the two sequences which are
    %    aligned
    %  bitmaskA & bitmaskB - bitmasks for seqA and seqB
    %   (seqA & seqB are aligned based only on the values
    %     and positions of the true bits in the bitmask
    %     corresponding to the data in the sequences_
    %  circularA & circularB - whether the sequences
    %   given should be treated like they are circular
    %   (e.g. allow circularly shifting them, respecting their
    %     periodic nature) as opposed to linear sequences
    %    (which cannot be circularly shifted and don't repeat)
    %  flipAtBestN - vectors whether the alignment required
    %    flipping one of the sequences in each top alignment
    %  circShiftAtBestN - Vector with the amount of circular
    %    shifting involved in each top alignment
    %  offsetAtBestN - Vectors containing the amount of linear
    %    offset for each alignment
    %
    % Outputs:
    %  aIndicesAtBestN & bIndicesAtBestN - cell arrays where each
    %    cell contains a vector of indices for the corresponding
    %    input sequence which are aligned together in order of best
    %    score produced for a given top alignment
    %  flipAtBestN - vectors whether the alignment required
    %    flipping one of the sequences in each top alignment
    %    (same as input)
    %  circShiftAAtBestN & circShiftBAtBestN - Vectors with the
    %    amount of circular shifting involved for each
    %    sequence in each top alignment
    import SignalRegistration.XcorrAlign.compute_alignment_params;

    topN = length(flipAtBestN);
    flipAtBestN = logical(flipAtBestN);

    if (circularA && not(circularB))
        [bIndicesAtBestN, aIndicesAtBestN] = compute_alignment_params(lenB, lenA, circularB, circularA, flipAtBestN, circShiftAtBestN, offsetAtBestN);
        for ii=1:topN
            if flipAtBestN(ii)
                aIndicesAtBestN{ii} = fliplr(aIndicesAtBestN{ii});
                bIndicesAtBestN{ii} = fliplr(bIndicesAtBestN{ii});
            end
        end
        return;
    end

    if not(circularA) && not(circularB)
        maxLen = max(lenA, lenB);
        notPaddingA = [1:lenA, zeros(1, maxLen - lenA)];
        notPaddingB = [1:lenB, zeros(1, maxLen - lenB)];

        aIndicesAtBestN = repmat(1:maxLen, topN, 1);
        bIndicesAtBestN = repmat(1:maxLen, topN, 1);
        aIndicesAtBestN = mat2cell(aIndicesAtBestN, ones(1, size(aIndicesAtBestN, 1)), size(aIndicesAtBestN, 2));
        bIndicesAtBestN = mat2cell(bIndicesAtBestN, ones(1, size(bIndicesAtBestN, 1)), size(bIndicesAtBestN, 2));
        for ii=1:topN
            aIndices = aIndicesAtBestN{ii};
            bIndices = bIndicesAtBestN{ii};

            if flipAtBestN(ii)
                aIndices = fliplr(aIndices) - offsetAtBestN(ii);
            else
                aIndices = aIndices + offsetAtBestN(ii);
            end
            indices = (aIndices > 0) & (aIndices <= lenB);
            aIndices = notPaddingA(aIndices(indices));
            bIndices = notPaddingB(bIndices(indices));
            nonPaddingIndices = ~((aIndices == 0) | (bIndices == 0));
            aIndices = aIndices(nonPaddingIndices);
            bIndices = bIndices(nonPaddingIndices);
            aIndicesAtBestN{ii} = aIndices;
            bIndicesAtBestN{ii} = bIndices;
        end
        return;
    end

    if circularA && circularB
        aIndicesAtBestN = repmat(1:max(lenA, lenB), topN, 1);
        bIndicesAtBestN = repmat(1:max(lenA, lenB), topN, 1);
        aIndicesAtBestN = mat2cell(aIndicesAtBestN, ones(1, size(aIndicesAtBestN, 1)), size(aIndicesAtBestN, 2));
        bIndicesAtBestN = mat2cell(bIndicesAtBestN, ones(1, size(bIndicesAtBestN, 1)), size(bIndicesAtBestN, 2));
        circShiftBAtBestN = circShiftAtBestN;
        circShiftBAtBestN(flipAtBestN) = -1*circShiftAtBestN(flipAtBestN);
        for ii=1:topN
            aIndices = aIndicesAtBestN{ii};
            bIndices = bIndicesAtBestN{ii};

            if flipAtBestN(ii)
                aIndices = fliplr(aIndices);
            end
            bIndices = circshift(bIndices, circShiftBAtBestN(ii), 2);

            aIndicesAtBestN{ii} = aIndices;
            bIndicesAtBestN{ii} = bIndices;
        end
        return;
    end

    aIndicesAtBestN = repmat(1:lenA, topN, 1);
    bIndicesAtBestN = repmat(1:lenB, topN, 1);
    aIndicesAtBestN(flipAtBestN,:) = fliplr(aIndicesAtBestN(flipAtBestN,:));
    for ii=1:topN
        bIndicesAtBestN(ii, :) = circshift(bIndicesAtBestN(ii, :), -1*circShiftAtBestN(ii), 2);
    end
    aIndicesAtBestN(flipAtBestN,:) = lenA + 1 - aIndicesAtBestN(flipAtBestN,:);

    aIndicesAtBestN = mat2cell(aIndicesAtBestN, ones(1, size(aIndicesAtBestN, 1)), size(aIndicesAtBestN, 2));
    bIndicesAtBestN = mat2cell(bIndicesAtBestN, ones(1, size(bIndicesAtBestN, 1)), size(bIndicesAtBestN, 2));

    minLen = min(lenA, lenB);
    startIdxBAtBestN = ones(topN, 1);
    endIdxBAtBestN = minLen*ones(topN, 1);
    endIdxBAtBestN(flipAtBestN,:) = lenB*ones(topN, 1);

    startIdxAAtBestN = offsetAtBestN + (lenA - lenB) + 1;
    endIdxAAtBestN = startIdxAAtBestN - 1 + lenB;
    startIdxAAtBestN = max(startIdxAAtBestN, 1);
    endIdxAAtBestN = min(endIdxAAtBestN, lenA);
    overLapLenAtBestN = endIdxAAtBestN - startIdxAAtBestN;

    startIdxBAtBestN(flipAtBestN,:) = endIdxBAtBestN(flipAtBestN,:) - overLapLenAtBestN;
    endIdxBAtBestN(~flipAtBestN,:) = startIdxBAtBestN(~flipAtBestN,:) + overLapLenAtBestN;


    rangeStartEndAAtBestN = [startIdxAAtBestN, endIdxAAtBestN];
    rangeStartEndBAtBestN = [startIdxBAtBestN, endIdxBAtBestN];

    for ii=1:topN
        if flipAtBestN(ii)
            aIndicedIndices = rangeStartEndAAtBestN(ii,2):-1:rangeStartEndAAtBestN(ii,1);
        else
            aIndicedIndices = rangeStartEndAAtBestN(ii,1):1:rangeStartEndAAtBestN(ii,2);
        end
        aIndices = aIndicesAtBestN{ii};
        aIndices = aIndices(aIndicedIndices);
        aIndicesAtBestN{ii} = aIndices;

        bIndicesIndices = rangeStartEndBAtBestN(ii,1):rangeStartEndBAtBestN(ii,2);
        bIndices = bIndicesAtBestN{ii};
        bIndices = bIndices(bIndicesIndices);
        bIndicesAtBestN{ii} = bIndices;
    end
end
