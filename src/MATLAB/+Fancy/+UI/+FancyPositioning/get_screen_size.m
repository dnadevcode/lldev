function [screenWidthPx, screenHeightPx] = get_screen_size()
    % GET_SCREEN_SIZE - gets the primary display's width and
    %    height in pixels (with some caveats)
    %  (Note: the values Matlab provides for this can sometimes be
    %    a little unreliable)
    %
    % Outputs:
    %   screenWidthPx
    %     the primary display's width in pixels (with some caveats)
    %   screenHeightPx
    %     the primary display's height in pixels (with some caveats)
    %
    % Caveats from Matlab:
    % -Starting in R2015b on Windows systems, the width and height
    %  values might differ from the screen size reported by the
    %  operating system. The values MATLAB reports are based on a
    %  ScreenPixelsPerInch ratio of 96:1. On Macintosh and Linux
    %  systems, the values match the size reported by the
    %  operating system.
    % -The values might not represent the usable display size due
    %  to the presence of UIs, such as the Microsoft® Windows
    %  task bar.
    % -MATLAB sets the display size values for this property at
    %  startup. The values are static. If your system display
    %  settings change, the display size values do not update.
    %  To refresh the values, restart MATLAB.
    %
    % Authors:
    %   Saair Quaderi
    
    if exist('groot', 'builtin')
        % groot introduced in R2014b
        graphicsRoot = groot;
    else
        % earlier value of 0
        graphicsRoot = 0;
    end
    
    oldUnits = get(graphicsRoot, 'Units');
    if strcmpi(oldUnits, 'pixels')
        screensizePx = get(graphicsRoot, 'ScreenSize');
    else
        set(graphicsRoot, 'Units', 'pixels');
        screensizePx = get(graphicsRoot, 'ScreenSize');
        set(graphicsRoot, 'Units', oldUnits);
    end
    
    screenWidthPx = screensizePx(3);
    screenHeightPx = screensizePx(4);
end