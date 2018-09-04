function [newRawKymos, newKymosFileIdxs, newKymosFileMoleculeIdxs] = create_and_set_all_missing_raw_kymos(dbmODW)
    import OldDBM.Kymo.DataBridge.create_raw_kymos;
    
    [fileIdxs, fileMoleculeIdxs] = dbmODW.get_molecule_idxs();
    [moleculeStatuses] = dbmODW.get_molecule_statuses(fileIdxs, fileMoleculeIdxs);
    hasRawKymoMask = moleculeStatuses.hasRawKymo;
    hasMovieMask = moleculeStatuses.hasMovie;
    createRawKymoMask = not(hasRawKymoMask) & hasMovieMask;
    newKymosFileIdxs = fileIdxs(createRawKymoMask);
    newKymosFileMoleculeIdxs = fileMoleculeIdxs(createRawKymoMask);
    [newRawKymos] = create_raw_kymos(dbmODW, newKymosFileIdxs, newKymosFileMoleculeIdxs);
    dbmODW.set_raw_kymos(newKymosFileIdxs, newKymosFileMoleculeIdxs, newRawKymos);
end