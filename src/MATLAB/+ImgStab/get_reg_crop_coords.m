function [regCropCoords, nondarkCropCoords] = get_reg_crop_coords(refGsImg, maxFiltWindowSz, nondarkCropCoords)
    % regCropCoords:
    %  an area of the image to look at for image registration
    % nondarkCropCoords:
    %  the area of the image which is determined not to be dark
    if (nargin < 2) || isempty(maxFiltWindowSz)
        maxFiltWindowSz = [255 255];
    end
    if (nargin < 3) || isempty(nondarkCropCoords)
        import ImgStab.find_nondark_region;
        nondarkCropCoords = find_nondark_region(refGsImg);
    end


    gsImgSz = size(refGsImg);
    refGsImgMainCropped = refGsImg(nondarkCropCoords.minRowIdx:nondarkCropCoords.maxRowIdx, nondarkCropCoords.minColIdx:nondarkCropCoords.maxColIdx);

    szRefGsImgMainCrop = size(refGsImgMainCropped);
    maxFiltWindowSz = min([szRefGsImgMainCrop; maxFiltWindowSz]); % filter window shouldn't be bigger than image
    maxFiltWindowSz = (2*ceil(maxFiltWindowSz./2)) - 1; % must be odd numbers on each side (round down)

    fprintf('Finding high variance nondark region...\n');
    tmpFilteredImg = stdfilt(refGsImgMainCropped, ones(maxFiltWindowSz));
    [~, maxLinIdx] = max(tmpFilteredImg(:));
    [maxValRowIdx, maxValColIdx] = ind2sub(szRefGsImgMainCrop, maxLinIdx);
    regCropCoords.minRowIdx = nondarkCropCoords.minRowIdx - 1 + maxValRowIdx - ceil(maxFiltWindowSz(1)/2);
    regCropCoords.maxRowIdx = regCropCoords.minRowIdx - 1 + maxFiltWindowSz(1);
    regCropCoords.minColIdx = nondarkCropCoords.minColIdx - 1 + maxValColIdx - ceil(maxFiltWindowSz(2)/2);
    regCropCoords.maxColIdx = regCropCoords.minColIdx - 1 + maxFiltWindowSz(2);
    regCropCoords.minRowIdx = max(1, regCropCoords.minRowIdx);
    regCropCoords.maxRowIdx = min(regCropCoords.maxRowIdx, gsImgSz(1));
    regCropCoords.minColIdx = max(1, regCropCoords.minColIdx);
    regCropCoords.maxColIdx = min(regCropCoords.maxColIdx, gsImgSz(2));
end