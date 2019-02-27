function [ccStructNoEdgeAdj] = get_filtered_cc_struct(fgMaskMov, minFramePresence, minLen, segmentFrameRot)
    % get_filtered_cc_struct
    
    % :param fgMaskMov: background mask
	% :param minFramePresence: parameter for how many frames should
	% component last
    % :param preprocessSettings: setting to process the movie
	% :param minLen: minimum length of the fragment
	% :param segmentFrameRot:  rotated frame with where the indice are not
	% zero

    %
    % :returns: ccStructNoEdgeAdj
    
    % rewritten by Albertas Dvirnas
    
    
    movSz = size(fgMaskMov);
    
    % ????
    % create a mask for a single frame containing everything outside of the
    %  main contiguous segment and everything touching it as well as every
    %  frame border pixel (the true values in the mask will all be in one
    %  connected component including pixel 1)
%     adjProblemFrameMask = (segmentFrameRot ~= 1);
%     adjProblemFrameMask = imdilate(adjProblemFrameMask, true(3, 3));
%     adjProblemFrameMask([1 end], 1) = true;
%     adjProblemFrameMask(1, [1 end]) = true;
    fgMaskMov = fgMaskMov & repmat(segmentFrameRot, [1, 1, movSz(3)]);
    
    %fgMaskMov = fgMaskMov | repmat(~segmentFrameRot, [1, 1, movSz(3:end)]);
    
    % find all connected components
    ccStruct = bwconncomp(fgMaskMov);
    
    % for each object find the first and last frame it appears in
    [~, ~, firstFrameIdxs] = ind2sub(ccStruct.ImageSize, cellfun(@(pixelLinIdxs) pixelLinIdxs(1), ccStruct.PixelIdxList));
    [~, ~, lastFrameIdxs] = ind2sub(ccStruct.ImageSize, cellfun(@(pixelLinIdxs) pixelLinIdxs(end), ccStruct.PixelIdxList));
    numFramesSpanned = 1 + lastFrameIdxs - firstFrameIdxs;
    
    numMovFrames = size(fgMaskMov, 3);
    if minFramePresence > numMovFrames
        minFramePresence = numMovFrames;
        warning('Reducing minimum frame presence requirement from %d to %d (the number of movie frames)', minFramePresence, numMovieFrames);
    end
    
    % remove those that are not present in all frames
    includeCcMask = (numFramesSpanned >= minFramePresence);
    ccStruct.NumObjects = sum(includeCcMask);
    ccStruct.PixelIdxList = ccStruct.PixelIdxList(includeCcMask);
    [~, tmp_so] = sort(cellfun(@length, ccStruct.PixelIdxList), 'descend');
    ccStruct.PixelIdxList = ccStruct.PixelIdxList(tmp_so);
    
    % remove molecules with maximum length less than minLen
    [I,J,K] =cellfun(@(x) ind2sub(size(fgMaskMov), x),ccStruct.PixelIdxList,'UniformOutput',false);
 	includeLengthMask = zeros(1,length(I));

    for jj=1:length(I)
        tempMaxMin = minLen;
        for kk=1:minFramePresence
            [a,~] = find(K{jj}==kk);
            tempMaxMin = min(tempMaxMin,max(I{jj}(a))-min(I{jj}(a)));
        end
        if tempMaxMin >= minLen
            includeLengthMask(jj) = 1;
        end
    end
    
    %includeLengthMask = cellfun(@(x) max(x)-min(x),I) >= minLen;
    ccStruct.NumObjects = sum(includeLengthMask);
    ccStruct.PixelIdxList = ccStruct.PixelIdxList(logical(includeLengthMask));
%     [~, tmp_so] = sort(cellfun(@length, ccStruct.PixelIdxList), 'descend');
%     ccStruct.PixelIdxList = ccStruct.PixelIdxList(tmp_so);
     
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