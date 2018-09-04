function [figureImgNoUI] = get_figure_image_noui(hFigure)
    hControls = findobj(hFigure, 'type', 'uicontrol');
    visibleMask = arrayfun(@(h) strcmpi('on', get(h, 'Visible')), hControls);
    arrayfun(@(h) set(h, 'Visible', 'off'), hControls(visibleMask));
    s = getframe(hFigure);
    arrayfun(@(h) set(h, 'Visible', 'on'), hControls(visibleMask));
    figureImgNoUI = s.cdata;
end