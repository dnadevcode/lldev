function [hAxesPlots] = plot_detected_raw_kymo_edges(dbmODW, fileIdxs, fileMoleculeIdxs, hParent, kymosMoleculeLeftEdgeIdxs, kymosMoleculeRightEdgeIdxs)

    rawKymos = dbmODW.get_raw_kymos(fileIdxs, fileMoleculeIdxs);

    kymoSrcFilenames = dbmODW.get_molecule_src_filenames(fileIdxs);

    numKymos = numel(rawKymos);
    numAxes = numKymos;

    import Fancy.UI.FancyPositioning.FancyGrid.generate_axes_grid;
    hAxesPlots = generate_axes_grid(hParent, numAxes);
    
    import OldDBM.General.UI.Helper.get_header_texts;
    headerTexts = get_header_texts(fileIdxs, fileMoleculeIdxs, kymoSrcFilenames);
    
    import OldDBM.Kymo.UI.show_kymos;
    show_kymos(rawKymos, hAxesPlots);

    import OldDBM.Kymo.UI.plot_kymo_edges;
    % Show the raw kymographs with labeled edges and header text on
    %  their alloted axis handles
    cellfun(@plot_kymo_edges, ...
        arrayfun(@(x) x, hAxesPlots(:), 'UniformOutput', false), ...
        kymosMoleculeLeftEdgeIdxs(:), ...
        kymosMoleculeRightEdgeIdxs(:));
    
    import OldDBM.General.UI.set_centered_header_text;
    for kymoNum = 1:numKymos
        hAxisPlot = hAxesPlots(kymoNum);
        headerText = headerTexts{kymoNum};
        set_centered_header_text(hAxisPlot, headerText, [1 1 0], 'none');
    end

end