function [endOverStartIntensityRatio] = calc_end_over_start_intensity_ratio(rawKymo, moleculeMask, bgIntensityApprox, largeDropNumKymoEndAreaFrames)
    rawKymoFgWithNaN = rawKymo;
    rawKymoFgWithNaN(~moleculeMask) = NaN;
    numFrames = size(rawKymoFgWithNaN, 1);
    if numFrames > largeDropNumKymoEndAreaFrames
        meanIntensityAboveBgStartFrames = nanmean(feval(@(vals) vals(:), rawKymoFgWithNaN(1:largeDropNumKymoEndAreaFrames, :))) - bgIntensityApprox;
        meanIntAboveBgEndFrames = nanmean(feval(@(vals) vals(:), rawKymoFgWithNaN(end + 1 - (1:largeDropNumKymoEndAreaFrames), :))) - bgIntensityApprox;
        endOverStartIntensityRatio = meanIntAboveBgEndFrames / meanIntensityAboveBgStartFrames;
    else
        endOverStartIntensityRatio = nan;
    end
end