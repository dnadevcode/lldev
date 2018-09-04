function [] = plot_kymo_and_edges(hAxis, rawKymo, leftEndIdxs, rightEndIdxs, headerText)

    axes(hAxis);
    imagesc(rawKymo);
    colormap(hAxis, gray);
    set(hAxis, 'YTick', []);
    set(hAxis, 'XTick', []);
    hold(hAxis, 'on');
    box('on');

    % Plot the kymograph's edges
    plot_kymo_edges(hAxis, leftEndIdxs, rightEndIdxs);
    
    import OldDBM.General.UI.set_centered_header_text;
    set_centered_header_text(hAxis, headerText, [1 1 0]);
    hold(hAxis, 'off');
end