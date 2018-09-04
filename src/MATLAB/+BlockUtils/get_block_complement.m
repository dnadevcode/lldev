function [blockComplement] = get_block_complement(maxIndex, blockBoundaries)
    if isempty(blockBoundaries)
        blockComplement = [1, maxIndex];
        return;
    end
    if isequal(blockBoundaries, [1, maxIndex])
        blockComplement = zeros(0,2);
        return;
    end
    blockStarts = blockBoundaries(:, 1);
    blockEnds = blockBoundaries(:, 2);

    atFirst = (blockStarts(1) == 1);
    atLast = (blockEnds(end) == maxIndex);

    if (atFirst)
        complementBlockEnds = blockStarts(2:end) - 1;
    else
        complementBlockEnds = blockStarts - 1;
    end
    if (atLast)
        complementBlockStarts = blockEnds(1:(end - 1)) + 1;
    else
        complementBlockStarts = blockEnds + 1;
    end

    if not(atFirst)
        complementBlockStarts = [1; complementBlockStarts];
    end
    if not(atLast)
        complementBlockEnds = [complementBlockEnds; maxIndex];
    end
    blockComplement = [complementBlockStarts, complementBlockEnds];
end
