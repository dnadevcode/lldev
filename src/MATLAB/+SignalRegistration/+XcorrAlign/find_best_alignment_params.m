function [aIndicesAtBestN, bIndicesAtBestN,...
        scoresAtBestN, xcorrAtBestN, coverageLenAtBestN,...
        scores, xcorrs, coverageLens,...
        firstOffset, maxPossibleCoverageLen] = find_best_alignment_params(...
            seqA, seqB, bitmaskA, bitmaskB, circularA, circularB, allowExtraCropping, topN, fn_compute_scores)
    % find_best_alignment_params
    %  Align a pair of bitmask-sequence pairs by flipping/shifting
    %    them and potentially cropping their sides as appropriate
    %     depending on whether or not they are circular or linear
    %
    % Inputs:
    %  seqA & seqB - the two sequences we wish to align
    %  bitmaskA & bitmaskB - bitmasks for seqA and seqB
    %   (seqA & seqB are aligned based only on the values
    %     and positions of the true bits in the bitmask
    %     corresponding to the data in the sequences_
    %  circularA & circularB - whether the sequences
    %   given should be treated like they are circular
    %   (e.g. allow circularly shifting them, respecting their
    %     periodic nature) as opposed to linear sequences
    %    (which cannot be circularly shifted and don't repeat)
    %  allowExtraCropping - for lin vs. circ, this allows cropping
    %    a side of the linear sequence -- down to as much as a
    %    final cropped sequence length of 2 (extreme offsets);
    %    for everthing else this is ignored. if false (default)
    %    the linear sequence can only be cropped down to the size
    %    of the circular sequence
    %  topN - the number of best alignments that should be
    %    in the output
    %  fn_compute_scores - optional custom function that takes in
    %    xcorrs, coverageLens, and maxPossibleCoverageLen and
    %    returns a scores array of the same dimensions as xcorrs
    %    and coverageLens where higher xcorrs and higher coverage
    %    results in higher scores
    %
    % Outputs:
    %  aIndicesAtBestN & bIndicesAtBestN - cell arrays where each
    %    cell contains a vector of indices for the corresponding
    %    input sequence which are aligned together in order of best
    %    score produced for a given top alignment
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
    %  scores - Weighted scores
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
    %  maxPossibleCoverageLen - maximum coverage length possible
    %    for the bitmasks in question

    if nargin < 3
        bitmaskA = true(size(a));
    end
    if nargin < 4
        bitmaskB = true(size(b));
    end

    if nargin < 5
        circularA = false;
    end
    if nargin < 6
        circularB = false;
    end

    if nargin < 7
        allowExtraCropping = false;
    end

    if nargin < 8
        topN = 1;
    end


    if nargin < 9
        import SignalRegistration.XcorrAlign.compute_scores;
        fn_compute_scores = @compute_scores;
    end
    
    seqA = seqA(:)';
    seqB = seqB(:)';
    bitmaskA = bitmaskA(:)';
    bitmaskB = bitmaskB(:)';
    
	import SignalRegistration.XcorrAlign.get_top_scores
    [scoresAtBestN, xcorrAtBestN, coverageLenAtBestN,...
        flipAtBestN, circShiftAtBestN, offsetAtBestN,...
        scores, xcorrs, coverageLens,...
        firstOffset, maxPossibleCoverageLen] =...
        get_top_scores(seqA, seqB, bitmaskA, bitmaskB, circularA, circularB, allowExtraCropping, topN, fn_compute_scores);

    lenA = length(seqA);
    lenB = length(seqB);
	import SignalRegistration.XcorrAlign.compute_alignment_params;
    [aIndicesAtBestN, bIndicesAtBestN] = compute_alignment_params(...
        lenA, lenB, circularA, circularB, flipAtBestN, circShiftAtBestN, offsetAtBestN);

end