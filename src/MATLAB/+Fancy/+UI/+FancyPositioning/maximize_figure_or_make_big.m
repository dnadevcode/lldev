function [maximizationSuccessTF] = maximize_figure_or_make_big(fh, paddingsLBRT)
    % MAXIMIZE_FIGURE_OR_MAKE_BIG - try to maximize the figure
    %  and if that doesn't work make it take up the screen size
    %
    % Inputs:
    %  fh
    %    a figure handle
    %
    %  paddingsLBRT (optional)
    %    vector of 4 padding values from left, bottom, right, and
    %    top edges of the screen
    %
    %    defaults to [0, 0, 0, 0]
    %
    % Outputs:
    %   maximizationSuccessTF
    %     true if the figure is successfully maximized
    %
    % Side-effects:
    %   if successful, maximizes the figure
    %   otherwise, sets the figure's edges to the edges of the
    %   screen but padded in accordance with paddingsLBRT
    %
    % Authors:
    %   Saair Quaderi
    
    import Fancy.UI.FancyPositioning.get_screen_size;
    import Fancy.UI.FancyPositioning.try_maximize_figure;
    import Fancy.UI.FancyPositioning.set_position;
    
    validateattributes(fh, {'matlab.ui.Figure'}, {}, 1);
    
    if nargin < 2
        defaultPaddingsLBRT = [0, 0, 0, 0];
        % an alternative that leaves some space for OS taskbar
        %  (e.g Windows taskbar) on the sides:
        % paddingsLBRT_default = [64, 36, 64, 36];

        paddingsLBRT = defaultPaddingsLBRT;
    else
        validateattributes(paddingsLBRT,...
            {'numeric'},...
            {'real', 'finite', 'size', [1, 4]},...
            2);
    end
    
    maximizationSuccessTF = try_maximize_figure(fh);
    if not(maximizationSuccessTF)
        [screenWidthPx, screenHeightPx] = get_screen_size();
        paddingLeft = paddingsLBRT(1);
        paddingBottom = paddingsLBRT(2);
        paddingRight = paddingsLBRT(3);
        paddingTop = paddingsLBRT(4);
        position = [1 + paddingLeft, 1 + paddingBottom, screenWidthPx - (paddingLeft + paddingRight), screenHeightPx - (paddingTop + paddingBottom)];
        set_position(fh, position, 'pixels', true);
    end
    drawnow;
end