function rgbVidArr = label2rgb_video(labeledGrayscaleVidArr)
   
    numLabels = double(max(labeledGrayscaleVidArr(:)));
    import ThirdParty.DistinguishableColors.distinguishable_colors;
    colorsArr = distinguishable_colors(numLabels);
    colorsArr = [[0 0 0]; colorsArr];
    
    sz = [size(labeledGrayscaleVidArr), 1, 1];
    sz = sz(1:4);
    if sz(3) ~= 1
        error('3rd dimension must have a length of 1');
    end
    
    frameSz = sz(1:2);
    rgbVidArr = zeros([frameSz, 3, sz(4)]);
    for frameIdx = 1:sz(4)
        frameColorIdxs = 1 + labeledGrayscaleVidArr(:, :, 1, frameIdx);
        rgbVidArr(:, :, 1, frameIdx) = reshape(colorsArr(frameColorIdxs, 1), frameSz);
        rgbVidArr(:, :, 2, frameIdx) = reshape(colorsArr(frameColorIdxs, 2), frameSz);
        rgbVidArr(:, :, 3, frameIdx) = reshape(colorsArr(frameColorIdxs, 3), frameSz);
    end
end