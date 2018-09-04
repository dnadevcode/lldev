function [bitmask] = get_bitmask_from_indices(indices, maxIndex)
    bitmask = false(maxIndex, 1);
    bitmask(indices) = true;
end