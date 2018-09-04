function [] = plot_intensity(hAxisIntensity, intensityCurve, filename, bindingNtSequence)
    titleStr = sprintf('%s in %s', bindingNtSequence, strrep(filename, '_', '-'));
    set(hAxisIntensity, 'FontSize', 10);
    plot(hAxisIntensity, 1:length(intensityCurve), intensityCurve);
    xlabel(hAxisIntensity, 'Position (bp)', 'FontSize', 11);
    ylabel(hAxisIntensity, 'Intensity', 'FontSize', 11);
    title(hAxisIntensity, titleStr);
end