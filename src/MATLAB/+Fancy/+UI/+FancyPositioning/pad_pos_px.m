function posPx = pad_pos_px(posPx, paddingPx, hasFixedOuterWidth, hasFixedOuterHeight)
% PAD_POS_PX - a
%
% Inputs:
%   posPx
%     1x4 position vector [left, bottom, width, height]
%   paddingPx
%     1x4 vector of padding
%        padding from left, padding from bottom, pa
%   fixedOuterWidth (optional, defaults to false)
%     whether the outer width should be fixed for the position
%   fixedOuterHeight (optional, defaults to false)
%     whether the outer height should be fixed for the position
%     
%
    if nargin < 3
        hasFixedOuterWidth = false;
    end
    if nargin < 4
        hasFixedOuterHeight = false;
    end
    posPx(1:2) = posPx(1:2) + paddingPx(1:2);
    posPx(3:4) = posPx(3:4) - paddingPx(3:4);
    if (hasFixedOuterWidth)
        posPx(3) = posPx(3) - paddingPx(1);
    end
    if (hasFixedOuterHeight)
        posPx(4) = posPx(4) - paddingPx(2);
    end
end