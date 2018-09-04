function [] = validate_block_boundaries(blockBoundaries, maxIndex, minIndex)
    if nargin < 2
        maxIndex = Inf;
    end
    if nargin < 3
        minIndex = 0;
    end
    if not(isempty((blockBoundaries)))
        if ((length(size(blockBoundaries)) ~= 2) || (size(blockBoundaries, 2) ~= 2))
            error('Bad dimensions');
        end
        ordered = blockBoundaries';
        ordered = ordered(:);
        diff_ordered = diff(ordered);
        if (any(diff_ordered(1:2:end) < 0))
            error('Bad indexing: a start index exceeds an end index');
        end
        if (any(diff_ordered(2:2:end) < 2))
            error('Bad indexing: a start index is not at least 2 greater than the previous end index');
        end
        if ((blockBoundaries(1, 1) < minIndex) || (blockBoundaries(2, end) > maxIndex))
            error('Indices exceed range');
        end
    end
end