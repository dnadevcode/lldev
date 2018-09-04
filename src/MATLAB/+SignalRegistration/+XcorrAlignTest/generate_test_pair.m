function [seqA, seqB, targetAIndices, targetBIndices, targetBestFlipped, targetBestCircShift] = generate_test_pair(circularA, circularB, aLen, bLen, snrA, snrB, minGenuineOverlap, flipVal)
    import SignalRegistration.XcorrAlignTest.generate_a_test_sequence;

    bothCircular = circularA && circularB;
    maxLen = max(aLen, bLen);
    minLen = min(aLen, bLen);
    if (minLen < 1)
        error('Both sequences must have positive lengths');
    end
    if (bothCircular && (maxLen ~= minLen))
        error('Circular sequences must have the same length');
    end
    if nargin < 5
        snrA = 3;
    elseif (snrA <= 0)
        error('Only positive signal-to-noise-ratios are permitted for sequence A.');
    end

    if nargin < 6
        snrB = 3;
    elseif (snrB <= 0)
        error('Only positive signal-to-noise-ratios are permitted for sequence B.');
    end

    if nargin < 7
        minGenuineOverlap = minLen;
    else
        if (minGenuineOverlap < 1)
            error('Sequences in a pair must have some overlap');
        elseif (minGenuineOverlap < minLen)
            if (bothCircular)
                error('Circular sequences in a pair must fully overlap.');
            end
        elseif (minGenuineOverlap > minLen)
            error('The minimum overlap can be no greater than the length of the shorter sequence in the pair.');
        end
    end

    if nargin < 8
        flipVal = randi([0,1]);
    end

    overlap = randi([minGenuineOverlap, minLen]);

    aFluffLen = aLen - overlap;
    bFluffLen = bLen - overlap;
    baseSeq = generate_a_test_sequence(aFluffLen + overlap + bFluffLen);
    noiseA = rand(1, aLen) - 0.5;
    noiseB = rand(1, bLen) - 0.5;
    nonMatchAtEndOfA = (overlap < minLen) && randi([0,1]);
    targetAIndicesIndices = 1:overlap;
    targetBIndicesIndices = 1:overlap;
    if (nonMatchAtEndOfA)
        seqB = baseSeq(1:bLen);
        seqA = baseSeq((1 + end - aLen):end);
        if circularB
            % rotate so that any fluff that seqB has is moved to
            % the end of the sequence, just like it is for seqA
            seqB = circshift(seqB, (0 - bFluffLen), 2);
        else
            targetBIndicesIndices = targetBIndicesIndices + bFluffLen;
            if (circularA)
                % since fluff for seqB is stuck at the start, try
                %   to move as much fluff to the start of seqA as
                %   seqB has, but stop before breaking up the
                %   overlapping sequence
                aFluffAtStart = min(aFluffLen, bFluffLen);
                seqA = circshift(seqA, aFluffAtStart, 2);
                targetAIndicesIndices = targetAIndicesIndices + aFluffAtStart;
            else
                aMiddling = randi([0, aFluffLen]);
                seqA = circshift(seqA, aMiddling, 2);
                targetAIndicesIndices = targetAIndicesIndices + aMiddling;

                bMiddling = randi([-1 * bFluffLen, 0]);
                seqB = circshift(seqB, bMiddling, 2);
                targetBIndicesIndices = targetBIndicesIndices + bMiddling;
            end
        end
    else %nonMatchAtStartOfA
        seqA = baseSeq(1:aLen);
        seqB = baseSeq((1 + end - bLen):end);
        if circularA
            % rotate so that any fluff that seqA has is moved to
            %   the end of the sequence, just like it is for seqB
            seqA = circshift(seqA, (0 - aFluffLen), 2);
        else
            targetAIndicesIndices = targetAIndicesIndices + aFluffLen;
            if (circularB)
                % since fluff for seqA is stuck at the start, try
                %   to move as much fluff to the start of seqB as
                %   seqA has, but stop before breaking up the
                %   overlapping sequence
                bFluffAtStart = min(aFluffLen, bFluffLen);
                seqB = circshift(seqB, bFluffAtStart, 2);
                targetBIndicesIndices = targetBIndicesIndices + bFluffAtStart;
            else
                aMiddling = randi([-1 * aFluffLen, 0]);
                seqA = circshift(seqA, aMiddling, 2);
                targetAIndicesIndices = targetAIndicesIndices + aMiddling;

                bMiddling = randi([0, bFluffLen]);
                seqB = circshift(seqB, bMiddling, 2);
                targetBIndicesIndices = targetBIndicesIndices + bMiddling;
            end
        end
    end
    seqA = seqA + noiseA/snrA;
    seqB = seqB + noiseB/snrB;

    aBackwardsIndices = 1:length(seqA);
    bBackwardsIndices = 1:length(seqB);

    targetBestFlipped = flipVal;

    if (targetBestFlipped)
        aBackwardsIndices = fliplr(aBackwardsIndices);
    end

    targetBestCircShift = randi([0, max(0, max(circularA*aLen, circularB*bLen) - 1)]);
    if (targetBestCircShift)
        if (circularA && (targetBestCircShift < aLen))
            seqA = circshift(seqA, -1 * targetBestCircShift, 2);
            aBackwardsIndices = circshift(aBackwardsIndices, targetBestCircShift, 2);
        else
            seqB = circshift(seqB, targetBestCircShift, 2);
            bBackwardsIndices = circshift(bBackwardsIndices, -1 * targetBestCircShift, 2);
            targetBestCircShift = -1 * targetBestCircShift;
        end
    end

    if (targetBestFlipped)
        seqA = fliplr(seqA);
    end

    targetAIndices = aBackwardsIndices(targetAIndicesIndices);
    targetBIndices = bBackwardsIndices(targetBIndicesIndices);
end
