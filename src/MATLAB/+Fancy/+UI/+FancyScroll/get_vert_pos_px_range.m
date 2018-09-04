function rangePx = get_vert_pos_px_range(goHandles)
    numHandles = length(goHandles);
    bottomPx = 0;
    topPx = 0;
    if (numHandles > 0)
        posPx = getpixelposition(goHandles(1));
        bottomPx = posPx(2);
        topPx = posPx(2) + posPx(4);
    end
    for handleNum=2:numHandles
        posPx = getpixelposition(goHandles(handleNum));
        bottomPx = min(bottomPx, posPx(2));
        topPx = max(topPx, posPx(2) + posPx(4));
    end
    rangePx = [bottomPx, topPx];
end