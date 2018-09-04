function [onlyBlockA, onlyBlockB] = get_block_diffs(blockBoundariesA, blockBoundariesB)
	import BlockUtils.get_block_diff;
    onlyBlockA = get_block_diff(blockBoundariesA, blockBoundariesB);
    onlyBlockB = get_block_diff(blockBoundariesB, blockBoundariesA);
end