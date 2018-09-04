function [outputImg] = apply_gaussian_blur(inputImg, smoothingWindow, gaussianSigmaWidth_pixels, tempPadMethod)
    % SMOOTH_IMG - smoothes an image (imgArr) using a moving average of window
    %	size smoothWindow
    %
    % Inputs:
    %  inputImg
    %    the input image
    %  smoothingWindow
    %    the size of the smoothing window
    %  gaussianSigmaWidth_pixels (optional; defaults to 10)
    %    the length of a single deviation of the gaussian the image will be
    %    convolved with (pixels)
    %  tempPadMethod (optional; defaults to 'replicate')
    %    either 'circular', 'replicate', or 'symmetric'
    %    determines the method used to temporarily pad the image
    %    before gaussian convolution so edges are treated as well
    %    as possible
    %
    % Outputs:
    %	outputImg
    %     smoothed version of the input
    %
    % Authors:
    %   Charleston Noble
    %   Saair Quaderi (refactored + corrected off-by-ones)
    if nargin < 3
        gaussianSigmaWidth_pixels = 10; % why 10?
    end
    if nargin < 4
        tempPadMethod = 'replicate';
    end

    H = fspecial('gaussian', smoothingWindow(1:2), gaussianSigmaWidth_pixels);

    paddingRows = smoothingWindow(1);
    paddingCols = smoothingWindow(2);
    outputImg = padarray(inputImg, [paddingRows, paddingCols], tempPadMethod, 'both');
    outputImg = conv2(outputImg, H, 'same');
    outputImg = outputImg((1 + paddingRows):(end - paddingRows), (1 + paddingCols):(end - paddingCols));    
end