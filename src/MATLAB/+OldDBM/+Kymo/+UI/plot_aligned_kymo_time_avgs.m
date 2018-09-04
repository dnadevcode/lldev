function [] = plot_aligned_kymo_time_avgs(hAxes, headerTexts, fgStartIdxs, fgEndIdxs, kymoTimeAvgs, kymoTimeStds, numsKymoFrames)
    import OldDBM.Kymo.UI.plot_aligned_kymo_time_avg;

    numMolecules = numel(hAxes);
    for moleculeNum=1:numMolecules
        hAxis = hAxes(moleculeNum);
        headerText = headerTexts{moleculeNum};
        fgStartIdx = fgStartIdxs(moleculeNum);
        fgEndIdx = fgEndIdxs(moleculeNum);
        kymoTimeAvg = kymoTimeAvgs{moleculeNum};
        kymoTimeStd = kymoTimeStds{moleculeNum};
        numKymoFrames = numsKymoFrames(moleculeNum);
        plot_aligned_kymo_time_avg(hAxis, headerText, fgStartIdx, fgEndIdx, kymoTimeAvg, kymoTimeStd, numKymoFrames);
    end
end