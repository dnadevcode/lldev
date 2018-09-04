function [bitmask] = generate_a_test_bitmask(bitmaskSize, maxNumZeroBlocks, zeroBlockLen)
    bitmask = true(bitmaskSize);
    zeroIndices = randi([1, length(bitmask) - zeroBlockLen], [randi([0, maxNumZeroBlocks]), 1]);
    zeroIndices = repmat(((1:zeroBlockLen) - 1), size(zeroIndices, 1), 1) + repmat(zeroIndices, 1, zeroBlockLen);
    zeroIndices = unique(zeroIndices(:));
    bitmask(zeroIndices) = false;
end