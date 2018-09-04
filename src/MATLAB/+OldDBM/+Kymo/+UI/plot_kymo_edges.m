function [] = plot_kymo_edges(hAxis, leftEndIdxs, rightEndIdxs)
    hold(hAxis, 'on');
    box('on');

    % Plot the kymograph's edges
    plot(hAxis, leftEndIdxs, 1:length(leftEndIdxs), 'm-', 'Linewidth', 2);
    plot(hAxis, rightEndIdxs, 1:length(rightEndIdxs), 'c-', 'Linewidth', 2);
    hold(hAxis, 'off');
end