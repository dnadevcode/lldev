function [blockDiff] = get_block_diff(blockBoundariesA, blockBoundariesB)
	import BlockUtils.get_block_complement;
	import BlockUtils.get_block_intersection;
    if (size(blockBoundariesA, 1) == 0)
        blockDiff = zeros(0,2);
        return;
    end
    if (size(blockBoundariesB, 1) == 0)
        blockDiff = blockBoundariesA;
        return;
    end
    maxIndex = max(blockBoundariesA(end, 2), blockBoundariesB(end, 2));
    complementBlockB = get_block_complement(maxIndex, blockBoundariesB);
    blockDiff = get_block_intersection(blockBoundariesA, complementBlockB);
end