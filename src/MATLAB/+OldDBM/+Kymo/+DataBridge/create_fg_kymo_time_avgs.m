function [fgKymoTimeAvgs, fgStartIdxs, fgEndIdxs] = create_fg_kymo_time_avgs(dbmODW, fileIdxs, fileMoleculeIdxs)
    import OldDBM.Kymo.Core.find_signal_region_with_otsu;
    
    numMolecules = numel(fileIdxs);
    fgKymoTimeAvgs = cell(numMolecules, 1);
    fgStartIdxs = NaN(numMolecules, 1);
    fgEndIdxs = NaN(numMolecules, 1);

    fileNames = dbmODW.get_molecule_src_filenames(fileIdxs);
    [alignedKymos, ~, ~] = dbmODW.get_aligned_kymos(fileIdxs, fileMoleculeIdxs);
    for moleculeNum = 1:numMolecules
        fileIdx = fileIdxs(moleculeNum);
        fileMoleculeIdx = fileMoleculeIdxs(moleculeNum);
        fileName = fileNames{moleculeNum};
        alignedKymo = alignedKymos{moleculeNum};
        if not(isempty(alignedKymo))
            fprintf('Averaging foreground of aligned kymograph for file molecule #%d in file #%d (%s)...\n', fileMoleculeIdx, fileIdx, fileName);
            kymoTimeAvg = nanmean(alignedKymo, 1);
            [fgStartIdx, fgEndIdx] = find_signal_region_with_otsu(kymoTimeAvg);
            fgStartIdx = ceil(fgStartIdx);
            fgEndIdx = floor(fgEndIdx);
            fgKymoTimeAvg = kymoTimeAvg(fgStartIdx:fgEndIdx);

            fgStartIdxs(moleculeNum) = fgStartIdx;
            fgEndIdxs(moleculeNum) = fgEndIdx;
            fgKymoTimeAvgs{moleculeNum} = fgKymoTimeAvg;
        end
    end
end