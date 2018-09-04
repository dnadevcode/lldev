function [] = plot_aligned_kymo_time_avg(hAxis, headerText, fgStartIdx, fgEndIdx, kymoTimeAvg, kymoTimeStd, numKymoFrames)
    kymoTimeStdErrOfMean = kymoTimeStd / sqrt(numKymoFrames);

    % find and plot edges
    startEdgePtsX = fgStartIdx*[1, 1];
    endEdgePtsX = fgEndIdx*[1, 1];
    startEdgePtsY = [min(kymoTimeAvg), max(kymoTimeAvg)];
    endEdgePtsY = startEdgePtsY;

    
    hold(hAxis, 'on');
    set(hAxis, 'Color', [0.7 0.7 0.7]);
    plot(hAxis, kymoTimeAvg, 'k');
    plot(hAxis, kymoTimeAvg + kymoTimeStdErrOfMean, 'r:');
    plot(hAxis, kymoTimeAvg - kymoTimeStdErrOfMean, 'r:');
    plot(hAxis, startEdgePtsX, startEdgePtsY, 'k--');
    plot(hAxis, endEdgePtsX, endEdgePtsY, 'k--');
    % ylabel(hAxis, 'I');
    % xlabel(hAxis, 'Position (pixels)');
    box(hAxis, 'on');
    axis(hAxis, 'tight');
    % Show the time-averaged kymograph.  
    import OldDBM.General.UI.set_centered_header_text;
    set_centered_header_text(hAxis, headerText, [1 1 0], 'none');
    hold(hAxis, 'off');
end