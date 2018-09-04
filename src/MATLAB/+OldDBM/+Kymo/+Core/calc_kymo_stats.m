function [kymoStatsStruct] = calc_kymo_stats(rawKymo, moleculeMask, moleculeLeftEdgeIdxs, moleculeRightEdgeIdxs)
    rawKymoFgWithNaN = rawKymo;
    rawKymoFgWithNaN(~moleculeMask) = NaN;

    meanFramewiseMoleculeIntensity = nanmean(rawKymoFgWithNaN, 2);
    stdFramewiseMoleculeIntensity = nanstd(rawKymoFgWithNaN, 0, 2);
    framewiseMoleculeExts = sum(moleculeMask, 2);


    meanOfFramewiseMoleculeExts = mean(framewiseMoleculeExts);
    stdOfFramewiseMoleculeExts = std(framewiseMoleculeExts);
    medianOfFramewiseMoleculeExts = median(framewiseMoleculeExts);
    madEstStdOfFramewiseMoleculeExts = 1.4826 * mad(framewiseMoleculeExts,1);

    rawKymoFgSansNaNs = rawKymoFgWithNaN;
    rawKymoFgSansNaNs(isnan(rawKymoFgSansNaNs)) = 0;
    unroundedMoleculeCenterOfMassIdxs = arrayfun(...
        @calc_center_of_mass_idx, ...
        (1:length(moleculeLeftEdgeIdxs))', moleculeLeftEdgeIdxs, moleculeRightEdgeIdxs);
    
    
    function centerOfMassIdx = calc_center_of_mass_idx(frameIdx, moleculeLeftEdgeIdx, moleculeRightEdgeIdx)
        if isnan(moleculeLeftEdgeIdx) || isnan(moleculeRightEdgeIdx)
            centerOfMassIdx = NaN;
            return;
        end
        try
            nrmCurveMainMolecule = rawKymoFgSansNaNs(frameIdx, moleculeLeftEdgeIdx:moleculeRightEdgeIdx);
        catch
            disp('');
        end
        centerOfMassIdx = sum((1:length(nrmCurveMainMolecule)) .* nrmCurveMainMolecule) / (sum(nrmCurveMainMolecule) * length(nrmCurveMainMolecule));
    end
    
    meanUnroundedCenterOfMassIdx = nanmean(unroundedMoleculeCenterOfMassIdxs);


    kymoStatsStruct.moleculeLeftEdgeIdxs = moleculeLeftEdgeIdxs;
    kymoStatsStruct.moleculeRightEdgeIdxs = moleculeRightEdgeIdxs;
    kymoStatsStruct.meanOfFramewiseMoleculeExts = meanOfFramewiseMoleculeExts;
    kymoStatsStruct.stdOfFramewiseMoleculeExts = stdOfFramewiseMoleculeExts;
    kymoStatsStruct.medianOfFramewiseMoleculeExts = medianOfFramewiseMoleculeExts;
    kymoStatsStruct.madEstStdOfFramewiseMoleculeExts = madEstStdOfFramewiseMoleculeExts;
    kymoStatsStruct.framewiseMoleculeExts = framewiseMoleculeExts;
    kymoStatsStruct.meanUnroundedCenterOfMassIdx = meanUnroundedCenterOfMassIdx;
    kymoStatsStruct.meanFramewiseMoleculeIntensity = meanFramewiseMoleculeIntensity;
    kymoStatsStruct.stdFramewiseMoleculeIntensity = stdFramewiseMoleculeIntensity;
end