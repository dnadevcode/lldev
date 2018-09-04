function [newFgKymoTimeAvgs, newFgStartIdxs, newFgEndIdxs] = create_and_set_all_missing_fg_kymo_time_avgs(dbmODW)

    [fileIdxs, fileMoleculeIdxs] = dbmODW.get_molecule_idxs();
    [moleculeStatuses] = dbmODW.get_molecule_statuses(fileIdxs, fileMoleculeIdxs);
    moleculesMissingFgKymoTimeAvgs = not(moleculeStatuses.hasFgKymoTimeAvg);
    moleculesMissingFgKymoTimeAvgs = moleculesMissingFgKymoTimeAvgs & moleculeStatuses.hasAlignedKymo;
    % moleculesMissingFgKymoTimeAvgs = moleculesMissingFgKymoTimeAvgs & moleculeStatuses.passesFilters;
    newFgKymoTimeAvgFileIdxs = fileIdxs(moleculesMissingFgKymoTimeAvgs);
    newFgKymoTimeAvgFileMoleculeIdxs = fileMoleculeIdxs(moleculesMissingFgKymoTimeAvgs);
    import OldDBM.Kymo.DataBridge.create_fg_kymo_time_avgs
    [newFgKymoTimeAvgs, newFgStartIdxs, newFgEndIdxs] = create_fg_kymo_time_avgs(dbmODW, newFgKymoTimeAvgFileIdxs, newFgKymoTimeAvgFileMoleculeIdxs);
    dbmODW.set_fg_kymo_time_avgs(newFgKymoTimeAvgFileIdxs, newFgKymoTimeAvgFileMoleculeIdxs, newFgKymoTimeAvgs);
end