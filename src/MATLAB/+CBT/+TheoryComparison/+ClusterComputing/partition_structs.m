function [theoryStructsPartials, partialStarts, partialEnds] = partition_structs(theoryStructs, partialMaxSizeInBytes)
    % breaks theory struct into smaller pieces based on byte sizes
    % so that they can be written to separate files or assigned to
    % be worked on by different computers
    numTheories = length(theoryStructs);
    sizesInBytes = zeros(numTheories, 1);
    for theoryNum=1:numTheories
        tmp = theoryStructs{theoryNum}; %#ok<NASGU>
        tmp2 = whos('tmp');
        sizesInBytes(theoryNum) = tmp2.bytes;
    end
    maxSizeInBytes = max(sizesInBytes);
    if partialMaxSizeInBytes < maxSizeInBytes
        error(['partialMaxSizeInBytes too small; minimum:', num2str(maxSizeInBytes)]);
    end
    cumSumSizesInBytes = cumsum(sizesInBytes);
    numPartials = ceil(sum(sizesInBytes)/partialMaxSizeInBytes);
    partialStarts = NaN(numPartials, 1);
    partialEnds = NaN(numPartials, 1);
    indexNextStart = 1;
    cumSumStart = 0;
    partialNum = 1;
    indexEnd = 0;
    while indexEnd <= numTheories
        indexEnd = find(cumSumSizesInBytes < (cumSumStart + partialMaxSizeInBytes), 1, 'last');
        partialStarts(partialNum) = indexNextStart;
        partialEnds(partialNum) = indexEnd;
        indexNextStart = indexEnd + 1;
    end
    theoryStructsPartials = arrayfun(@(startIdx, endIdx) ...
        theoryStructs(startIdx:endIdx), ...
        partialStarts, partialEnds, 'UniformOutput', false);
end