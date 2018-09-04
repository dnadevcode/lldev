function [blockBoundaries] = block_circ_shift(maxIndex, blockBoundaries, shift)
    % import BlockUtils.validate_block_boundaries;
	% validate_block_boundaries(blockBoundaries);
	
    shift = mod(shift, maxIndex); % circular shift can be represented by a value from [0, maxIndex - 1]
    if (isempty(blockBoundaries) || (shift == 0)) % nothing to do
        return;
    end
    if ((blockBoundaries(1, 1) == 1) && (blockBoundaries(end, 2) == maxIndex)) % consolidate broken up block at index-edges if it exists
        blockBoundaries(end, 2) = maxIndex + blockBoundaries(1, 2); % this will temporarily go out of range, but that will be corrected later with mod
        blockBoundaries = blockBoundaries(2:end, :);
    end
    blockBoundaries = blockBoundaries + shift;
    ii = find(blockBoundaries(:, 1) > maxIndex, 1, 'first'); % find index for first case where the start of a block exceeds maxIndex
    jj = [];
    if not(isempty(ii))
        if (ii > 1) && (blockBoundaries(ii - 1, 2) > maxIndex)
            jj = ii - 1; % if the end of preceding block also exceeded maxIndex, get its index
        end
    elseif blockBoundaries(end, 2) > maxIndex % otherwise if no ii was found
        jj = size(blockBoundaries, 1);  % if the end of the last block exceeded maxIndex, get its index
    end
    if not(isempty(jj))
        blockBoundaries(jj, 2) = mod(blockBoundaries(jj, 2) - 1, maxIndex) + 1; % if jj exists, use modulus to correct its index back into range
    end
    if not(isempty(ii))
        blockBoundaries(ii:end, :) = mod(blockBoundaries(ii:end, :) - 1, maxIndex) + 1; % correct all other indices that exceed maxIndex back into range
        blockBoundaries = circshift(blockBoundaries, 1 - ii); % circshift so that indices remain in ascending order
    end
    if (blockBoundaries(end, 2) < blockBoundaries(end, 1)) % if the last block ends after maxIndex (indicated by wrapped around value), break it up
        blockBoundaries = [1, blockBoundaries(end, 2); blockBoundaries(1:(end - 1), :); blockBoundaries(end, 1), maxIndex];
    end
end
