function normalizedVerticalScrollPosPx = get_normalized_vscroll_pos_px(contentViewportHeightRatio, verticalScrollVal, normalizedLeftPos, normalizedWidth)
    if nargin < 3
        normalizedLeftPos = 0;
    end
    if nargin < 4
        normalizedWidth = 1;
    end
    normalizedVerticalScrollPosPx = [normalizedLeftPos, (1 - contentViewportHeightRatio) * verticalScrollVal, normalizedWidth, contentViewportHeightRatio];
end