function [hTabMLH] = add_molecule_lengths_hist_tab(ts, moleculeLengths_pixels)
    % ADD_MOLECULE_LENGTHS_HIST_TAB - Plots the distribution of molecule
    %   lengths in a histogram in a new tab
    %
    % Inputs:
    %   ts
    %      TabbedScreen object
    %   moleculeLengths_pixels
    %      vector of molecule lengths (in pixels)
    %
    %  Outputs:
    %    hTabMLH
    %      the handle for the created tab
    %
    % Authors:
    %  Saair Quaderi

    hTabMLH = ts.create_tab('Molecule Length Distribution');
    hPanel = uipanel('Parent', hTabMLH);
    hAxis = axes('Parent', hPanel);
    hist(hAxis, moleculeLengths_pixels);
    set(get(hAxis,'child'), 'FaceColor', 'k', 'EdgeColor', 'k');
    xlabel(hAxis, 'Length (pixels)')
    ylabel(hAxis, 'Molecules')
end