function [blockUnion] = get_block_union(blockBoundariesA, blockBoundariesB)
	import BlockUtils.get_union;
	
    blockA_starts = blockBoundariesA(:, 1);
    blockA_ends = blockBoundariesA(:, 2);

    blockB_starts = blockBoundariesB(:, 1);
    blockB_ends = blockBoundariesB(:, 2);

    all_starts = get_union(blockA_starts, blockB_starts);
    all_max_ends = zeros(size(all_starts));

    num_starts = length(all_starts);
    if (num_starts == 0)
        blockUnion = zeros(0, 2);
        return;
    end
    if (num_starts == 1)
        blockUnion = [all_starts, max([blockA_ends, blockB_ends])];
        return;
    end
    block_union_idx = 0;
    blockUnion = zeros(num_starts, 2);
    a_ii = 1;
    b_ii = 1;
    max_a_ii = length(blockA_ends);
    max_b_ii = length(blockB_ends);
    for ii=1:num_starts
        start = all_starts(ii);
        max_end = start;
        if (a_ii <= max_a_ii) && (blockA_starts(a_ii) == start)
            max_end = max(max_end, blockA_ends(a_ii));
            a_ii = a_ii + 1;
        end
        if (b_ii <= max_b_ii) && (blockB_starts(b_ii) == start)
            max_end = max(max_end, blockB_ends(b_ii));
            b_ii = b_ii + 1;
        end
        all_max_ends(ii) = max_end;
    end
    starts_ends = [all_starts, all_max_ends]';
    starts_ends = starts_ends(:);
    n = num_starts*2;
    curr_start_idx = 1;
    curr_start = starts_ends(curr_start_idx);
    curr_end = starts_ends(curr_start_idx + 1);
    next_start_idx = curr_start_idx + 2;
    next_start = starts_ends(next_start_idx);
    next_end = starts_ends(next_start_idx + 1);
    done = false;
    while not(done)
        while next_start <= (curr_end + 1)
            curr_end = max(curr_end, next_end);
            next_start_idx = next_start_idx + 2;
            if (next_start_idx > n - 1)
                done = true;
                break
            end
            next_start = starts_ends(next_start_idx);
            next_end = starts_ends(next_start_idx + 1);
        end
        block_union_idx = block_union_idx + 1;
        blockUnion(block_union_idx, :) = [curr_start, curr_end];
        if not(done)
            curr_start = next_start;
            curr_end = next_end;
            if (next_start_idx > n - 1)
                block_union_idx = block_union_idx + 1;
                blockUnion(block_union_idx, :) = [curr_start, curr_end];
                done = true;
            else
                next_start = starts_ends(next_start_idx);
                next_end = starts_ends(next_start_idx + 1);
            end
        end
    end
    blockUnion = blockUnion(1:block_union_idx, :);
end
