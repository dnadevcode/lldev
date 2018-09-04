function nondarkCropCoords = find_nondark_region(gsImg)
    % nondarkCropCoords:
    %  the area of the image which is determined not to be dark
    fprintf('Finding nondark region...\n');
    maxVal = (2^8)^(2^ceil(log(log(max(double(gsImg(:))))/log(2^8))/log(2)));
    expansivenessOfRegion = 6; % 1 includes nothing, larger values include darker regions

    mask = (gsImg >= maxVal/expansivenessOfRegion);
    CC = bwconncomp(mask);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [~, largestCCIdx] = max(numPixels);
    [rowIdxs, colIdxs] = ind2sub(CC.ImageSize, CC.PixelIdxList{largestCCIdx});
    nondarkCropCoords.minRowIdx = min(rowIdxs);
    nondarkCropCoords.maxRowIdx = max(rowIdxs);
    nondarkCropCoords.minColIdx = min(colIdxs);
    nondarkCropCoords.maxColIdx = max(colIdxs);
end