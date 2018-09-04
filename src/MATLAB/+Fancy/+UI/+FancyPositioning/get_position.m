function [position] = get_position(hGO, units)
    % GET_POSITION - gets positiona of a graphics object with a
    %   given set of units or defaulting to 'pixels' without making any
    %   lasting change to the object's units
    %
    % Inputs:
    %  hGO
    %    a graphics object handle
    %
    %  units (optional, defaults to 'pixels')
    %    the units to get the position for specified in the format
    %    [left, bottom, width, height] (the matlab standard)
    %
    % Outputs:
    %   position
    %     the position of the graphics object in the specified units
    %
    % Authors:
    %   Saair Quaderi
    
    if not(isequal(isgraphics(hGO), true))
        error('Input must be a scalar graphic object handle');
    end
    
    if (nargin < 2) || strcmpi(units, 'pixels')
        position = getpixelposition(hGO);
    else
        oldUnits = get(hGO, 'Units');
        if strcmpi(oldUnits, tmpUnits)
            position = get(hGO, 'Position');
        else
            set(hGO, 'Units', tmpUnits);
            position = get(hGO, 'Position');
            set(hGO, 'Units', oldUnits);
        end
    end
end