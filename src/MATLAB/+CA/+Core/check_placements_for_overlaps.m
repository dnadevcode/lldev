function [numOverlap] = check_placements_for_overlaps(placementIdxs, contigLengths, numPlacementOptions, allowOverlap, allowFlippingTF, forcingPlacementTF)
    % Checks if there are any overlaps between "contigs" in the assignment
    % problem.

    numOverlap = 0;
    if isempty(placementIdxs)
        return;
    end

    placementIdxs = placementIdxs(:);
    contigLengths = contigLengths(:);

    nonPlacementIdxs = [];
    flipPlacementIdxs = [];
    if forcingPlacementTF
        refSeqLen = numPlacementOptions;
    else
        refSeqLen = numPlacementOptions - 1;
        nonPlacementIdxs = numPlacementOptions;  % by our convention last spot represents no placement (if forcingPlacementTF)
    end
    if allowFlippingTF
        refSeqLen = refSeqLen/2; % by our convention second half represents placement with flips (if allowFlippingTF)
        flipPlacementIdxs = ((1:refSeqLen) + refSeqLen)';
    end

    nonplacedContigMask = arrayfun(@(placementIdx) any(placementIdx == nonPlacementIdxs), placementIdxs);
    flipPlacedContigMask = arrayfun(@(placementIdx) any(placementIdx == flipPlacementIdxs), placementIdxs);

    startIdxs = placementIdxs;
    startIdxs(flipPlacedContigMask) = placementIdxs(flipPlacedContigMask) - refSeqLen;


    % Remove all contigs that are no placed on the experiment.
    startIdxs(nonplacedContigMask) = [];
    contigLengths(nonplacedContigMask) = [];


    if length(startIdxs) < 2
        return;
    end

    % Sort them by placement so that only neighbours are compared
    tmpMat = sortrows([startIdxs, contigLengths]);
    sortedStartIdxs = tmpMat(:, 1);
    lenIdxsSortedByStartIdxs = tmpMat(:, 2);

    % Calculate the end of the contigs (using length + start position)
    endIdxsSortedByStartIdxs = -1 + sortedStartIdxs + lenIdxsSortedByStartIdxs;
    precedingEndIdxsSortedByStartIdxs = circshift(endIdxsSortedByStartIdxs, 1); % Shift the ends to make comparison easier
    precedingEndIdxsSortedByStartIdxs(1) = precedingEndIdxsSortedByStartIdxs(1) - refSeqLen; % adjust for cyclical reference

    % Compare
    if allowOverlap
        numOverlap = max(0, precedingEndIdxsSortedByStartIdxs - sortedStartIdxs + 1);
    else
        numOverlap = double(any(precedingEndIdxsSortedByStartIdxs >= sortedStartIdxs));
    end
end