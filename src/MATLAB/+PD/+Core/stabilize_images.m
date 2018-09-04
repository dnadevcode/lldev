function [regImgs, nondarkCropCoords, tforms] = stabilize_images(imgRetriever, allowRotationTF, imgRefIdx)
    if nargin < 1
        import PD.ImageRetriever;
        imgRetriever = ImageRetriever();
        imgRetriever.add_bayer_dngs();
    end
    if nargin < 2
        allowRotationTF = false;
    end
    if allowRotationTF
        transformType = 'rigid';
    else
        transformType = 'translation';
    end
    if nargin < 3
        imgRefIdx = 1;
    end
    
    numImgs = imgRetriever.get_image_count();
    if numImgs < 2
        error('Need at least two images');
    end
    regImgs = cell(numImgs, 1);
    tforms = cell(numImgs, 1);
    
    fprintf('Importing reference image...\n');
    [successTF, refImg] = imgRetriever.retrieve_image(imgRefIdx);
    if not(successTF)
        error('Failed to acquire reference image (image #%d)...', imgRefIdx);
    end
    if isempty(refImg)
        error('Empty reference image detected');
    end
    
    fprintf('Generating grayscale reference image...\n');
    refGsImg = mean(refImg, 3);
    refImgSz = size(refGsImg);
    rOutputView = imref2d(refImgSz);
    
    import PD.Core.get_reg_crop_coords;
    [regCropCoords, nondarkCropCoords] = get_reg_crop_coords(refGsImg, []);
    
    refGsImgCropped = refGsImg(regCropCoords.minRowIdx:regCropCoords.maxRowIdx, regCropCoords.minColIdx:regCropCoords.maxColIdx);
    
    metric = registration.metric.MeanSquares;
    optimizer = registration.optimizer.RegularStepGradientDescent;
    
    import Fancy.UI.FancyInput.dropdown_dialog;
    for imgIdx = 1:numImgs
        if imgIdx == imgRefIdx
            regImgs{imgIdx} = refImg;
            tforms{imgIdx} = affine2d(eye(3));
            continue;
        end
        fprintf('Importing image #%d...\n', imgIdx);

        [successTF, currImg] = imgRetriever.retrieve_image(imgIdx);
        if not(successTF)
            error('Failed to acquire image #%d...', imgIdx);
        end
        currImgSz = size(currImg);
        if not(isequal(currImgSz(1:2), refImgSz(1:2))) && isequal(currImgSz(1:2), refImgSz([2, 1]))
            rotationDir = dropdown_dialog('Rotation Selection', sprintf('Choose direction to rotate image #%d', imgIdx), {'Counter-clockwise'; 'Clockwise'});
            switch rotationDir
                case 'Counter-clockwise'
                    currImg = rot90(currImg);
                case 'Clockwise'
                    currImg = rot90(currImg, 3);
            end
            currImgSz = size(currImg);
        end
        if not(isequal(refImgSz(1:2), currImgSz(1:2)))
            error('Images must be the same size');
        end
        
        fprintf('Generating cropped grayscale image #%d...\n', imgIdx);
        currGsImgCropped = mean(currImg(regCropCoords.minRowIdx:regCropCoords.maxRowIdx, regCropCoords.minColIdx:regCropCoords.maxColIdx), 3);
        
        fprintf('Registering cropped grayscale image #%d...\n', imgIdx);
        
        tformCropped = imregtform(currGsImgCropped, refGsImgCropped, transformType, optimizer, metric);

        fprintf('Converting transform coordinates...\n');
        t = eye(3);
        t = mtimes(t, [1, 0, 0; 0, 1, 0; 1 - regCropCoords.minColIdx, 1 - regCropCoords.minRowIdx, 1]);
        t = mtimes(t, tformCropped.T);
        t = mtimes(t, [1, 0, 0; 0, 1, 0; regCropCoords.minColIdx - 1, regCropCoords.minRowIdx - 1, 1]);
        tform = affine2d(t);
        
        currGsRegImg = cell(3, 1);
        for channelIdx = 1:3
            fprintf('Warping image color channel %d...\n', channelIdx);
            [currGsRegImg{channelIdx}, ~] = imwarp(currImg(:, :, channelIdx), tform, 'OutputView', rOutputView);
        end
        
        tforms{imgIdx} = tform;
        regImgs{imgIdx} = cat(3, currGsRegImg{:});
    end
    regImgs = cat(4, regImgs{:});
end