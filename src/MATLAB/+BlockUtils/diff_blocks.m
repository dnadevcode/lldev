function [onlyBlockA, onlyBlockB, blockIntersection, blockUnion] = diff_blocks(blockBoundariesA, blockBoundariesB)
    import BlockUtils.get_block_diffs;
    import BlockUtils.get_block_intersection;
    import BlockUtils.get_block_union;
	
    [onlyBlockA, onlyBlockB] = get_block_diffs(blockBoundariesA, blockBoundariesB);
    blockIntersection = get_block_intersection(blockBoundariesA, blockBoundariesB);
    blockUnion = get_block_union(blockBoundariesA, blockBoundariesB);
end