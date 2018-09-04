function [rawKymos] = create_raw_kymos(dbmODW, fileIdxs, fileMoleculeIdxs)
    numMolecules = numel(fileIdxs);
    rawKymos = cell(numMolecules, 1);
    fileNames = dbmODW.get_molecule_src_filenames(fileIdxs);
    for moleculeNum=1:numMolecules
        fileIdx = fileIdxs(moleculeNum);
        fileMoleculeIdx = fileMoleculeIdxs(moleculeNum);
        fileName = fileNames{moleculeNum};
        [miniMovie] = dbmODW.get_mini_movie(fileIdx, fileMoleculeIdx);
        if not(isempty(miniMovie))
            fprintf('Creating kymograph for file molecule #%d in file #%d (%s)...\n', fileMoleculeIdx, fileIdx, fileName);
            rawFlatKymo = permute(mean(miniMovie, 2), [3 1 2]);
        end
        rawKymos{moleculeNum} = rawFlatKymo;
    end
end