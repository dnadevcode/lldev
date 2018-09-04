function widthPx = get_pixel_width(goHandle)
    % GET_PIXEL_WIDTH - returns the width of the graphics object in pixels
    %
    % Inputs:
    %   goHandle
    %     the handle of the graphics object
    %
    % Outputs:
    %   widthPx
    %     the width of the graphics object in pixels
    %
    % Authors:
    %   Saair Quaderi
    posPx = getpixelposition(goHandle);
    widthPx = posPx(3);
end