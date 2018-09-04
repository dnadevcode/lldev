function [] = add_bg_zeroed_kymo_tab(tsKymo, rawKymoBgZeroed)
    % Show the kymograph with background removed
    hTabBgRmvd = tsKymo.create_tab('Background Removed');
    hTabPanelBgRmvd = uipanel('Parent', hTabBgRmvd);
    hAxisBgRmvd = gca('Parent', hTabPanelBgRmvd);

    axes(hAxisBgRmvd);
    imagesc(rawKymoBgZeroed);
    colormap(hAxisBgRmvd, gray());
end