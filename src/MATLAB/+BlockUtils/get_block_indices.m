function [blockIndices] = get_block_indices(blockBoundaries)
	% import BlockUtils.validate_block_boundaries;
    % validate_block_boundaries(blockBoundaries);
    % e.g. [a, b; c, d; e, f; ...] => [a:b, c:d, e:f, ...]
    blockIndices = cell2mat(cellfun( @(x) x(1):x(2), num2cell(blockBoundaries, 2), 'UniformOutput', false)');
end