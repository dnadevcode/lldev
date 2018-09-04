function [alignedKymos, stretchFactorsMats, shiftAlignedKymos] = create_aligned_kymos(dbmODW, fileIdxs, fileMoleculeIdxs)
    numMolecules = numel(fileIdxs);
    alignedKymos = cell(numMolecules, 1);
    stretchFactorsMats = cell(numMolecules, 1);
    shiftAlignedKymos = cell(numMolecules, 1);
    fileNames = dbmODW.get_molecule_src_filenames(fileIdxs);
    [rawKymos] = dbmODW.get_raw_kymos(fileIdxs, fileMoleculeIdxs);
    import OptMap.KymoAlignment.NRAlign.nralign;
    for moleculeNum = 1:numMolecules
        fileIdx = fileIdxs(moleculeNum);
        fileMoleculeIdx = fileMoleculeIdxs(moleculeNum);
        fileName = fileNames{moleculeNum};
        rawKymo = rawKymos{moleculeNum};
        if not(isempty(rawKymo))
            fprintf('Aligning kymograph for file molecule #%d in file #%d (%s)...\n', fileMoleculeIdx, fileIdx, fileName);
            [alignedKymo, stretchFactorsMat, shiftAlignedKymo] = nralign(rawKymo);
            alignedKymos{moleculeNum} = alignedKymo;
            stretchFactorsMats{moleculeNum} = stretchFactorsMat;
            shiftAlignedKymos{moleculeNum} = shiftAlignedKymo;
        end
    end
end