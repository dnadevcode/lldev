function [blockIntersection] = get_block_intersection(blockBoundariesA, blockBoundariesB)
	import BlockUtils.get_block_complement;
	import BlockUtils.get_block_union;
    nA = size(blockBoundariesA, 1);
    nB = size(blockBoundariesB, 1);
    if (min(nA, nB) == 0)
        blockIntersection = zeros(0,2);
        return;
    end
    maxIndex = max(blockBoundariesA(end, 2), blockBoundariesB(end, 2));
    complementBlockA = get_block_complement(maxIndex, blockBoundariesA);
    complementBlockB = get_block_complement(maxIndex, blockBoundariesB);
    complementUnion = get_block_union(complementBlockA, complementBlockB);
    blockIntersection = get_block_complement(maxIndex, complementUnion);
end
