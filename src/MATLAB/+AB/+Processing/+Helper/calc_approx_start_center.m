function roundedStartCenterCoords = calc_approx_start_center(kymosCenterXYCoord)
    % calc_approx_start_center - calculate approximate molecule center
    %
    % :param settings: input parameter.
    % :returns: calc_approx_start_center
    
    % rewritten by Albertas Dvirnas
    
    frameIdx = 1;
    if not(isempty(kymosCenterXYCoord))
        roundedStartCenterCoords = round(kymosCenterXYCoord(frameIdx, 1:2));
    else
        roundedStartCenterCoords = [];
        disp('debug');
    end
end