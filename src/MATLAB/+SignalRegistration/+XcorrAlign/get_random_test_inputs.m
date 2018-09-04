function [seqA, seqB, bitmaskA, bitmaskB, circularA, circularB, allowExtraCropping, topN, targetAIndices, targetBIndices, targetBestFlipped, targetBestCircShift] = get_random_test_inputs(circularA, circularB, flipVal, allowExtraCropping, lens)
    if nargin < 1
        circularA = logical(randi([0, 1]));
    end
    if nargin < 2
        circularB = logical(randi([0, 1]));
    end
    if nargin < 3
        flipVal = randi([0, 1]);
    end
    if nargin < 4
        allowExtraCropping = false;
    end
    if nargin < 5
        lens = [120, 130];
    end

    minLen = min(lens);
    maxLen = max(lens);
    if not(circularA && circularB)
        aLen = lens(randi([1, 2]));
        bLen = lens(randi([1, 2]));
    else
        aLen = maxLen;
        bLen = maxLen;
    end
    maxLen = max(aLen, bLen);
    snrA = 4;
    snrB = 4;
    if circularA && circularB
        minGenuineOverlap = maxLen;
    else
        minGenuineOverlap = minLen - randi([0, round(minLen/2)]);
    end

    % generate related sequences
    import SignalRegistration.XcorrAlignTest.generate_test_pair;
    [seqA, seqB, targetAIndices, targetBIndices, targetBestFlipped, targetBestCircShift] = generate_test_pair(circularA, circularB, aLen, bLen, snrA, snrB, minGenuineOverlap, flipVal);
    topN = 1;

    % generate bitmasks
    maxNumZeroBlocks = 4;
    zeroBlockLen = 5;

    import SignalRegistration.XcorrAlignTest.generate_a_test_bitmask;
    bitmaskA = generate_a_test_bitmask(size(seqA), maxNumZeroBlocks, zeroBlockLen);
    bitmaskB = generate_a_test_bitmask(size(seqB), maxNumZeroBlocks, zeroBlockLen);
end