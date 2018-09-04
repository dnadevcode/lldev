function [] = add_com_aligned_kymo_tab(tsKymo, comAlignedKymo)
    % Show the center of mass aligned kymograph
    
    hTabCOMAK = tsKymo.create_tab('Center of Mass Aligned Kymo');
    hTabPanelCOMAK = uipanel('Parent', hTabCOMAK);
    hAxisBgCOMAK = gca('Parent', hTabPanelCOMAK);

    axes(hAxisBgCOMAK);
    imagesc(comAlignedKymo),
    colormap(hAxisBgCOMAK, gray());
    box(hAxisBgCOMAK, 'on')
end