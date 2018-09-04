function [removedBlockIndices, addedBlockIndices, removedBlock, addedBlock, blockBoundariesCircShifted] = get_block_circ_shift_diff_indices(maxIndex, blockBoundaries, shift)
    import BlockUtils.block_circ_shift;
	import BlockUtils.get_block_diffs;
	import BlockUtils.get_block_indices;
	
    blockBoundariesCircShifted = block_circ_shift(maxIndex, blockBoundaries, shift);
    [removedBlock, addedBlock] = get_block_diffs(blockBoundaries, blockBoundariesCircShifted);
    removedBlockIndices = get_block_indices(removedBlock);
    addedBlockIndices = get_block_indices(addedBlock);
end
