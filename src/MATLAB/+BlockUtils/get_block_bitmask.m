function [bitmask] = get_block_bitmask(blockBoundaries, maxIndex)
	import BlockUtils.get_block_indices;
	import BlockUtils.get_bitmask_from_indices;
    bitmask = get_bitmask_from_indices(get_block_indices(blockBoundaries), maxIndex);
end