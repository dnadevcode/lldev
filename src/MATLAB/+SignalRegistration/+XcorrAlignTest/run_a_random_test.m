function [] = run_a_random_test(circularA, circularB, flipVal, allowExtraCropping, lens)
    import SignalRegistration.XcorrAlignTest.test_inputs;
    import SignalRegistration.XcorrAlignTest.get_random_test_inputs;
    
    % but function get_random_test_inputs does not exist..
    
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
    [seqA, seqB, bitmaskA, bitmaskB, circularA, circularB, allowExtraCropping, topN, targetAIndices, targetBIndices, targetBestFlipped, targetBestCircShift] = get_random_test_inputs(circularA, circularB, flipVal, allowExtraCropping, lens);

    test_inputs(seqA, seqB, bitmaskA, bitmaskB, circularA, circularB, allowExtraCropping, topN, targetAIndices, targetBIndices, targetBestFlipped, targetBestCircShift);
end
