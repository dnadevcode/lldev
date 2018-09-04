function [] = show_raw_kymos(dbmODW, hParent)
    [rawKymos, rawKymoFileIdxs, rawKymoFileMoleculeIdxs] = dbmODW.get_all_existing_raw_kymos();
    [kymoSrcFilenames] = dbmODW.get_molecule_src_filenames(rawKymoFileIdxs);

    numAxes = numel(rawKymos);

    import Fancy.UI.FancyPositioning.FancyGrid.generate_axes_grid;
    hAxesRawKymos = generate_axes_grid(hParent, numAxes);
    
    import OldDBM.General.UI.Helper.get_header_texts;
    headerTexts = get_header_texts(rawKymoFileIdxs, rawKymoFileMoleculeIdxs, kymoSrcFilenames);
    
    import OldDBM.Kymo.UI.show_kymos;
    show_kymos(rawKymos, hAxesRawKymos, headerTexts);
end