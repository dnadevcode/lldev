function [ccStructNoEdgeAdj] = get_filtered_cc_struct(fgMaskMov, minFramePresence, segmentFrameRot)
    movSz = size(fgMaskMov);
    % create a mask for a single frame containing everything outside of the
    %  main contiguous segment and everything touching it as well as every
    %  frame border pixel (the true values in the mask will all be in one
    %  connected component including pixel 1)
    adjProblemFrameMask = (segmentFrameRot ~= 1);
    adjProblemFrameMask = imdilate(adjProblemFrameMask, true(3, 3));
    adjProblemFrameMask([1 end], 1) = true;
    adjProblemFrameMask(1, [1 end]) = true;
    fgMaskMov = fgMaskMov | repmat(adjProblemFrameMask, [1, 1, movSz(3:end)]);
    
    ccStruct = bwconncomp(fgMaskMov);
    [~, ~, ~, firstFrameIdxs] = ind2sub(ccStruct.ImageSize, cellfun(@(pixelLinIdxs) pixelLinIdxs(1), ccStruct.PixelIdxList));
    [~, ~, ~, lastFrameIdxs] = ind2sub(ccStruct.ImageSize, cellfun(@(pixelLinIdxs) pixelLinIdxs(end), ccStruct.PixelIdxList));
    numFramesSpanned = 1 + lastFrameIdxs - firstFrameIdxs;

    
    numMovFrames = size(fgMaskMov, 4);
    if minFramePresence > numMovFrames
        minFramePresence = numMovFrames;
        warning('Reducing minimum frame presence requirement from %d to %d (the number of movie frames)', minFramePresence, numMovieFrames);
    end
    
    includeCcMask = (numFramesSpanned >= minFramePresence);
    ccStruct.NumObjects = sum(includeCcMask);
    ccStruct.PixelIdxList = ccStruct.PixelIdxList(includeCcMask);
    [~, tmp_so] = sort(cellfun(@length, ccStruct.PixelIdxList), 'descend');
    ccStruct.PixelIdxList = ccStruct.PixelIdxList(tmp_so);
    
    % removes border-adjacent molecules presuming all border adjacent
    %   molecules are connected to the pixel with index 1
    containsFirstPixelMask = cellfun(@(list) list(1) == 1, ccStruct.PixelIdxList);
    ccStructNoEdgeAdj = ccStruct;
    ccStructEdgeAdj = ccStruct;

    ccStructNoEdgeAdj.NumObjects = sum(~containsFirstPixelMask);
    ccStructEdgeAdj.NumObjects = sum(containsFirstPixelMask);

    ccStructNoEdgeAdj.PixelIdxList = ccStructEdgeAdj.PixelIdxList(~containsFirstPixelMask);
    ccStructEdgeAdj.PixelIdxList = ccStructEdgeAdj.PixelIdxList(containsFirstPixelMask);
end