function [selectionFileIdxs, selectionFileMoleculeIdxs] = select_for_alignment(dbmODW, fileIdxs, fileMoleculeIdxs)
    if nargin < 2
        [fileIdxs, fileMoleculeIdxs] = dbmODW.get_molecule_idxs();
    end
    [moleculeStatuses] = dbmODW.get_molecule_statuses(fileIdxs, fileMoleculeIdxs);
    hasAlignedKymoMask = moleculeStatuses.hasAlignedKymo;
    hasRawKymoMask = moleculeStatuses.hasRawKymo;
    canCreateAlignedKymoMask = not(hasAlignedKymoMask) & hasRawKymoMask;

    fileIdxs = fileIdxs(canCreateAlignedKymoMask);
    fileMoleculeIdxs = fileMoleculeIdxs(canCreateAlignedKymoMask);


    [moleculeStatuses] = dbmODW.get_molecule_statuses(fileIdxs, fileMoleculeIdxs);
    selectionMask = moleculeStatuses.passesFilters;

    selectionFileIdxs = fileIdxs(selectionMask);
    selectionFileMoleculeIdxs = fileMoleculeIdxs(selectionMask);
end