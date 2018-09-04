function [newAlignedKymos, newAlignedKymoFileIdxs, newAlignedKymoFileMoleculeIdxs] = create_and_set_all_missing_aligned_kymos(dbmODW)
    import OldDBM.Kymo.DataBridge.create_and_set_all_missing_raw_kymos;
    create_and_set_all_missing_raw_kymos(dbmODW);
    
    import OldDBM.Kymo.DataBridge.select_for_alignment;
    [newAlignedKymoFileIdxs, newAlignedKymoFileMoleculeIdxs] = select_for_alignment(dbmODW);

    import OldDBM.Kymo.DataBridge.create_aligned_kymos;
    [newAlignedKymos, newStretchFactorsMats, newShiftAlignedKymos] = create_aligned_kymos(dbmODW, newAlignedKymoFileIdxs, newAlignedKymoFileMoleculeIdxs);
    dbmODW.set_aligned_kymos(newAlignedKymoFileIdxs, newAlignedKymoFileMoleculeIdxs, newAlignedKymos, newStretchFactorsMats, newShiftAlignedKymos);
end