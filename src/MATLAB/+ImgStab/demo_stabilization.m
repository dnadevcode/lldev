import ImgStab.ImageRetriever;
imgRetriever = ImageRetriever();
imgRetriever.add_bayer_dngs();

allowRotationTF = false;
imgRefIdx = 1;

import ImgStab.stabilize_images;
[regImgs, nondarkCropCoords] = stabilize_images(imgRetriever, allowRotationTF, imgRefIdx);
regImgCropped = regImgs(nondarkCropCoords.minRowIdx:nondarkCropCoords.maxRowIdx, nondarkCropCoords.minColIdx:nondarkCropCoords.maxColIdx, :, :);


timeStr = datestr(clock(), 'yyyy-mm-dd HH_MM_SS');

dirpath = pwd();
saveStabilizedImgsTF = true;
if saveStabilizedImgsTF
    stabilizedPg1OutputPath = sprintf('%s_stabilized_pg_1.tiff', timeStr);
    stabilizedPg1OutputPath = fullfile(dirpath, stabilizedPg1OutputPath);
    [stabilizedPg1OutputPath, dirpath] = uiputfile('*_1.tiff', 'Select pg 1 tiff output', stabilizedPg1OutputPath);
    if not(isequal(dirpath, 0))
        stabilizedPg1OutputPath = fullfile(dirpath, stabilizedPg1OutputPath);
        prefixStr = stabilizedPg1OutputPath(1:(end - 7));

        numFrames = size(regImgCropped, 4);
        for frameNum = 1:numFrames
            imwrite(uint16(round(regImgCropped(:,:,:,frameNum))), sprintf('%s_%d.tiff', prefixStr, frameNum));
        end
    else
        dirpath = pwd();
    end
end

saveMeanImgTF = true;
if saveMeanImgTF
    meanOutputPath = sprintf('%s_cropped_mean.tiff', timeStr);
    meanOutputPath = fullfile(dirpath, meanOutputPath);
    [meanOutputPath, dirpath] = uiputfile('*.tiff', 'Select mean tiff output', meanOutputPath);
    if not(isequal(dirpath, 0))
        meanOutputPath = fullfile(dirpath, meanOutputPath);
        meanRegImgCropped = mean(regImgCropped, 4);
        imwrite(uint16(round(meanRegImgCropped)), meanOutputPath);
    end
end


implay(regImgCropped);
