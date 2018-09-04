function [blockBoundaries] = block_lin_shift(maxIndex, blockBoundaries, shift, blockFill)
    % import BlockUtils.validate_block_boundaries;
	% validate_block_boundaries(blockBoundaries);
	
    if nargin < 4
        blockFill = false;
    end
    shift = sign(shift) * min(abs(shift), maxIndex); % keep sign of shift, but limit magnitude to maxIndex
    if (shift == 0) % nothing to do
        return;
    end

    if isempty(blockBoundaries) % no existing blocks
        if blockFill
            if (shift > 0)
                % introduce as block at start of range
                blockBoundaries = [1, shift];
            else
                % introduce as block at end of range
                blockBoundaries = [maxIndex + 1 - shift, maxIndex];
            end
        end
    else
        if shift > 0 % must shift rightwards
            if blockFill
                if blockBoundaries(1, 1) == 1 % extend existing left-hand-side block
                    blockBoundaries = blockBoundaries + shift;
                    blockBoundaries(1, 1) = 1;
                else % introduce new block ar left-hand-side
                    blockBoundaries = [[1, shift]; blockBoundaries + shift];
                end
            else
                blockBoundaries = blockBoundaries + shift;
            end
            ii = find(blockBoundaries(:, 1) <= maxIndex, 1, 'last');
            if (isempty(ii)) % everything must now be out of range
                blockBoundaries = [];
            else % crop whatever is out of range on right-hand-side
                blockBoundaries = blockBoundaries(1:ii, :);
                blockBoundaries(end, 2) = min(blockBoundaries(end, 2), maxIndex);
            end
            return;
        else % must shift leftwards
            if blockFill
                if blockBoundaries(end, 2) == maxIndex % extend existing right-hand-side block
                    blockBoundaries = blockBoundaries + shift;
                    blockBoundaries(end, 2) = maxIndex;
                else % introduce new block at right-hand-side
                    blockBoundaries = [blockBoundaries + shift; [maxIndex + 1 + shift, maxIndex]];
                end
            else
                blockBoundaries = blockBoundaries + shift;
            end
            ii = find(blockBoundaries(:, 2) >= 1, 1, 'first');
            if (isempty(ii)) % everything must now be out of range
                blockBoundaries = [];
            else % crop whatever is out of range on left-hand-side
                blockBoundaries = blockBoundaries(ii:end, :);
                blockBoundaries(1, 1) = max(blockBoundaries(1, 1), 1);
            end
            return;
        end
    end
end