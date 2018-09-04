function [paddedImage] = pad_image(inputImg, padVal, paddingTop, paddingLeft, paddingBottom, paddingRight)
    % PAD_IMAGE - pads an image with a certain pad value at the top, bottom,
    %   left, and right
    %
    % Inputs:
    %   inputImg
    %     the image to be padded
    %   padVal
    %     the value to occupy the padded areas
    %   paddingTop
    %     how much padding (in pixels) should be added to the top of the
    %     image
    %   paddingLeft
    %     how much padding (in pixels) should be added to the left of the
    %     image
    %   paddingBottom
    %     how much padding (in pixels) should be added to the bottom of the
    %     image
    %   paddingRight
    %     how much padding (in pixels) should be added to the right of the
    %     image
    %
    % Outputs:
    %   paddedImage
    %     the padded version of the image
    %
    % Authors:
    %   Saair Quaderi
    
    paddedImage = padarray(padarray(inputImg, [paddingTop, paddingLeft], padVal, 'pre'), [paddingBottom, paddingRight], padVal, 'post');
end

