function [blockBoundaries] = get_block_boundaries(bitmask, getZeros)
    bitmask = bitmask(:);
    if not(islogical(bitmask))
        error('bitmask must be logical');
    end
    if nargin < 2
        getZeros = false;
    end
    % blocks of 1s are detected by default, but blocks of 0s
    %  are detected instead if getZeros is true
    x = not(getZeros);
    delta = diff([x; bitmask; x]);
    edges = find(delta);
    blockBoundaries = [edges(1:2:end), (edges(2:2:end) - 1)];
end
