function [removedBlockIndices, addedBlockIndices, removedBlock, addedBlock, blockBoundariesLinShifted] = get_block_lin_shift_diff_indices(maxIndex, blockBoundaries, shift)
    import BlockUtils.block_lin_shift;
	import BlockUtils.get_block_diffs;
	import BlockUtils.get_block_indices;
	
	blockBoundariesLinShifted = block_lin_shift(maxIndex, blockBoundaries, shift);
    [removedBlock, addedBlock] = get_block_diffs(blockBoundaries, blockBoundariesLinShifted);
    removedBlockIndices = get_block_indices(removedBlock);
    addedBlockIndices = get_block_indices(addedBlock);
end