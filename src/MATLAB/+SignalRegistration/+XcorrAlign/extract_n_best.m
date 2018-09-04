function [scoresAtBestN, xcorrAtBestN, coverageLenAtBestN, flipAtBestN, circShiftAtBestN, offsetAtBestN] = extract_n_best(scores, xcorrs, coverageLens, firstOffset, topN)
    % extract_n_best
    %  Extracts the n best alignments that are found from
    %   the provided xcorrs ad coverageLens arrays
    %
    % Inputs:
    %  scores - Weighted scores for xcorrs/coverageLens
    %    (a function with a direct relationship to
    %      Pearson cross-correlation coefficient
    %      and the coverage length in proportion to the
    %      maximum coverage length possible for the bitmasks
    %      in question)
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
    %  firstOffset - offset to be used to make sense of the
    %    indices for the third dimension of xcorrs
    %  topN - the number of best alignments that should be
    %    in the output
    %
    % Outputs:
    %  Note: All are vectors where the kth entry corresponds to the
    %   kth best alignment as determined by the score
    %  scoresAtBestN - Weighted scores for best alignment
    %    (a function with a direct relationship to
    %      Pearson cross-correlation coefficient
    %      and the coverage length in proportion to the
    %      maximum coverage length possible for the bitmasks
    %      in question) 
    %  xcorrAtBestN - Pearson cross-correlation coefficients for
    %    each top alignment
    %  coverageLenAtBestN - Effective sample sizes for each top
    %    alignment (i.e. the amount of shared bitmask overlap)
    % Note: the following three are useful for reproducing
    %     the alignment via compute_alignment_params
    %     but the sequence lengths and circularities
    %     also need to be provided
    %  flipAtBestN - vectors whether the alignment required
    %    flipping one of the sequences in each top alignment
    %  circShiftAtBestN - Vector with the amount of circular
    %    shifting involved in each top alignment
    %  offsetAtBestN - Vectors containing the amount of linear
    %    offset for each alignment
    if nargin < 5
        topN = 1;
    end
    maxIndex = numel(xcorrs);
    topN = max(1, min(maxIndex, topN));

    allScores = scores(:);
    [scoresAtBestN, indsBestN] = sort(allScores(1:topN));

    for ii=(topN + 1):maxIndex
        score = allScores(ii);
        if (scoresAtBestN(end) < score)
            jj = find(scoresAtBestN <= score, 1, 'first');
            scoresAtBestN = [scoresAtBestN(1:(jj-1)); score; scoresAtBestN(jj:(topN - 1))];
            indsBestN = [indsBestN(1:(jj-1)); ii; indsBestN(jj:(topN - 1))];
        end
    end
    matDims = size(xcorrs);

    [ind1s, ind2s, ind3s] = ind2sub(matDims, indsBestN);
    xcorrAtBestN = zeros(topN, 1);
    coverageLenAtBestN = zeros(topN, 1);
    for ii=1:topN
        xcorrAtBestN(ii) = xcorrs(ind1s(ii), ind2s(ii), ind3s(ii));
        coverageLenAtBestN(ii) = coverageLens(ind1s(ii), ind2s(ii), ind3s(ii));
    end
    flipAtBestN = logical(ind1s - 1);
    circShiftAtBestN = ind2s - 1;
    offsetAtBestN = ind3s - 1 + firstOffset;
end
