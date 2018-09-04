function [kymosMoleculeLeftEdgeIdxs, kymosMoleculeRightEdgeIdxs, kymosMoleculeMask, rawKymos, rawKymoFileIdxs, rawKymoFileMoleculeIdxs] = run_raw_kymos_edge_detection(dbmODW, skipDoubleTanhAdjustment)
    
    [rawKymos, rawKymoFileIdxs, rawKymoFileMoleculeIdxs] = dbmODW.get_all_existing_raw_kymos();
    srcFilenames = dbmODW.get_molecule_src_filenames(rawKymoFileIdxs);
    numMolecules = length(rawKymoFileMoleculeIdxs);
    kymosMoleculeLeftEdgeIdxs = cell(numMolecules, 1);
    kymosMoleculeRightEdgeIdxs = cell(numMolecules, 1);
    kymosMoleculeMask = cell(numMolecules, 1);
    
    import OptMap.MoleculeDetection.EdgeDetection.get_default_edge_detection_settings;
    edgeDetectionSettings = get_default_edge_detection_settings(skipDoubleTanhAdjustment);
    
    import OptMap.MoleculeDetection.EdgeDetection.approx_main_kymo_molecule_edges;
    for moleculeNum = 1:numMolecules
        srcFilename = srcFilenames{moleculeNum};
        rawKymoFileIdx = rawKymoFileIdxs(moleculeNum);
        rawKymoFileMoleculeIdx = rawKymoFileMoleculeIdxs(moleculeNum);
        fprintf('Finding edges for molecule %d in %s\n', rawKymoFileMoleculeIdx, srcFilename);
        rawKymo = rawKymos{moleculeNum};

        [kymoMoleculeLeftEdgeIdxs, kymoMoleculeRightEdgeIdxs, kymoMoleculeMask] = approx_main_kymo_molecule_edges(rawKymo, edgeDetectionSettings);
        kymosMoleculeLeftEdgeIdxs{moleculeNum} = kymoMoleculeLeftEdgeIdxs;
        kymosMoleculeRightEdgeIdxs{moleculeNum} = kymoMoleculeRightEdgeIdxs;
        kymosMoleculeMask{moleculeNum} = kymoMoleculeMask;
    end
end