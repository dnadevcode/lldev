function [pxPositions, pxSizes, pixelpositionMat] = get_coords_px(hGOs)
    % GET_COORDS_PX - provides position and size info in pixels
    %    for graphics objects
    %
    % Inputs:
    %  hGOs
    %    graphics object handle(s)
    %
    % Outputs:
    %  pxPositions
    %    a struct contain fields: left, right, bottom, top
    %    containing the appropriate pixel position information
    %    for the edges of the components as a vector
    %
    %  pxSizes
    %    a struct contain fields: width, height
    %    containing pixel width and height information
    %    of the components as a vector
    %
    %  pixelpositionMat
    %    a matrix containing the output of getpixelposition
    %    as a simple matrix (left, bottom, width, height)
    %    in each row for each component
    %
    % Authors:
    %   Saair Quaderi

    if any(not(isgraphics(hGOs)))
        error('Input must only contain graphic object handles');
    end

    pixelpositionMat = getpixelposition(hGOs);
    if iscell(pixelpositionMat)
        pixelpositionMat = cell2mat(pixelpositionMat);
    end
    pxSizes.width = pixelpositionMat(:, 3);
    pxSizes.height = pixelpositionMat(:, 4);
    pxPositions.left = pixelpositionMat(:, 1);
    pxPositions.right = pxPositions.left + pxSizes.width;
    pxPositions.bottom = pixelpositionMat(:, 2);
    pxPositions.top = pxPositions.bottom + pxSizes.height;
end