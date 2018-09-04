function [] = plot_expected_binding_locations(hAxisBindingLocs, intensityCurve, filename, bindingNtSequence)
    titleStr = sprintf('%s in %s (without psf)', bindingNtSequence, strrep(filename, '_', '-'));
    set(hAxisBindingLocs, 'FontSize', 10, 'YTick', [0, 1]);
    plot(hAxisBindingLocs, 1:length(intensityCurve), intensityCurve);
    xlabel(hAxisBindingLocs, 'Position (bp)', 'FontSize', 11);
    ylabel(hAxisBindingLocs, 'Intensity', 'FontSize', 11);
    title(hAxisBindingLocs, titleStr);
end