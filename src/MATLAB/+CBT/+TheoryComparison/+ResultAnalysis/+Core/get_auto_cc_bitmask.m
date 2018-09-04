function [bitmaskAutoCCs] = get_auto_cc_bitmask(theoryDataHashes, getAutoCCsFromHashValues)
    if getAutoCCsFromHashValues % if we want all hash duplicates (including but not limited to the diagonal)
        bitmaskAutoCCs = cellfun(@(x) strcmp(x, theoryDataHashes), theoryDataHashes, 'UniformOutput', false); % find duplicate sequences
        bitmaskAutoCCs = [bitmaskAutoCCs{:}]; % convert into matrix
    else % diagonal only
        bitmaskAutoCCs = logical(eye(length(theoryDataHashes))); % matrix of diagonal of auto-ccs
    end
end