function [] = add_single_time_trace_tab(tsKymo, rawKymo, rawKymoBgZeroed, frameNumSTT)
    rawKymoSTT = rawKymo(frameNumSTT, :);
    rawKymoBgZeroedSTT = rawKymoBgZeroed(frameNumSTT, :);
        
    % Show single time trace
    tabTitle = sprintf('Single Time Trace, (frame #%d)', frameNumSTT);
    hTabSTT = tsKymo.create_tab(tabTitle);
    hTabPanelSTT = uipanel('Parent', hTabSTT);
    hAxisSTT = gca('Parent', hTabPanelSTT);

    plot(hAxisSTT, rawKymoBgZeroedSTT, 'b--');
    hold(hAxisSTT, 'on');
    plot(hAxisSTT, rawKymoSTT, 'r-');
end