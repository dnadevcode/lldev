function [] = save_image(rgbImg, filepath)
    % SAVE_IMAGE - saves an image to a file
    %
    % Inputs:
    %  rgbImg
    %    image data that can be saved with imwrite (e.g. an MxNx3 matrix
    %    with values between 0 and 1 where the three MxN matrices represent
    %    values in Red, Green, and Blue)
    %
    %  filepath: (optional)
    %   the filepath for where the image should be saved if it is already
    %   known, if not the user will be prompted to provide a destination
    %   filepath
    %
    % Side-effects:
    %   prompts the user for a filepath if one is not provided, and rights
    %   the image to the filepath
    %
    % Authors:
    %   Saair Quaderi
    
    if nargin < 2
        [filename, filedirpath] = uiputfile(...
            {'*.png'; '*.tiff'; '*.jpg'; '*.bmp'; '*.gif'},...
            'Save image as');
        if filename ~= 0
            filepath = fullfile(filedirpath, filename);
        else
            return;
        end
    else
        validateattributes(filepath, {'char'}, {'vector'}, 2);
    end
    imwrite(rgbImg, filepath);
end