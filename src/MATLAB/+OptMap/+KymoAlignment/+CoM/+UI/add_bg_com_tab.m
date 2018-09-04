function [] = add_bg_com_tab(tsKymo, rawKymo, centerOfMass)
    % Show raw kymograph with center of mass on top
    [numRows, ~] = size(rawKymo);
    rowNums = 1:numRows;
    roundedCenterOfMass = round(centerOfMass(rowNums));

    hTabBgCOM = tsKymo.create_tab('Center of Mass');
    hTabPanelBgCOM = uipanel('Parent', hTabBgCOM);
    hAxisBgCOM = gca('Parent', hTabPanelBgCOM);

    axes(hAxisBgCOM);
    imagesc(rawKymo);
    colormap(hAxisBgCOM, gray());
    hold(hAxisBgCOM, 'on');
    plot(roundedCenterOfMass, rowNums, 'm*', 'Linewidth', 3);
end