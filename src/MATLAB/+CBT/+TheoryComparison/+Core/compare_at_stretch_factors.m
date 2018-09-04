function [bestCC, meanCC, stdCC, bestStretchFactor] = compare_at_stretch_factors(stretchFactors, thyCurve_bpRes, psfSigmaWidth_bp, pixelsPerBp, otherCurve_pxRes, otherCurveBitmask)
    import CBT.Core.apply_stretching;
    import Microscopy.Simulate.Core.apply_point_spread_function;
    import CBT.Core.convert_bpRes_to_pxRes;
    import SignalRegistration.XcorrAlign.get_no_extra_cropping_lin_circ_xcorrs;

    numStretchFactors = length(stretchFactors);
    if ((numStretchFactors == 0) || isempty(thyCurve_bpRes) || isempty(otherCurve_pxRes))
        bestCC = NaN;
        meanCC = NaN;
        stdCC = NaN;
        bestStretchFactor = NaN;
        return;
    end
    thyCurve_bpRes_sf = cell(numStretchFactors, 1);
    thyCurve_pxRes_sf = cell(numStretchFactors, 1);
    thyCurveBitmask_sf = cell(numStretchFactors, 1);
    allCCs = cell(numStretchFactors, 1); %for mean/deviation calculations
    bestCC_sf = zeros(numStretchFactors, 1);
    for sfIdx = 1:numStretchFactors
        stretchFactor = stretchFactors(sfIdx);

        % Stretch/compress based on stretch factor
        thyCurve_bpRes_sf{sfIdx} = apply_stretching(thyCurve_bpRes, stretchFactor);

        % Smooth in basepair resolution by convolving curve with PSF
        thyCurve_bpRes_sf{sfIdx} = apply_point_spread_function(thyCurve_bpRes_sf{sfIdx}, psfSigmaWidth_bp);

        % Convert to pixel resolution (and also reisner-rescale)
        thyCurve_pxRes_sf{sfIdx} = convert_bpRes_to_pxRes(thyCurve_bpRes_sf{sfIdx}, pixelsPerBp);
        thyCurve_pxRes_sf{sfIdx} = zscore(thyCurve_pxRes_sf{sfIdx});

        % compute best Pearson cross-correlation coefficient & alignment:
        thyCurveBitmask_sf{sfIdx} = true(size(thyCurve_pxRes_sf{sfIdx}));

        [xcorrs, ~, ~] = get_no_extra_cropping_lin_circ_xcorrs(otherCurve_pxRes, thyCurve_pxRes_sf{sfIdx}, otherCurveBitmask, thyCurveBitmask_sf{sfIdx});

        bestCC_sf(sfIdx) = max(xcorrs(:));
        allCCs{sfIdx} = xcorrs;
    end

    % get very best cross-correlation from all the best
    %   cross-correlations for individual stretch factors
    [bestCC, sfIdx] = max(bestCC_sf);

    % Compute aligned sequences/bitmasks in accordance with best
    %  cross correlation at best stretch factor
    % (for purposes of plotting and what not)

    bestStretchFactor = stretchFactors(sfIdx);

    % Compute cc-value means and standard deviations
    % (combined over all cc's calculated over all the stretch factors)

    numCCs = 0;
    for sfIdx = 1:numStretchFactors
        numCCs = numCCs + numel(allCCs{sfIdx});
    end
    allCCsVector = zeros(numCCs, 1);
    ccIndex = 1;
    for sfIdx = 1:numStretchFactors
        ccs = allCCs{sfIdx};
        numCC = numel(ccs);
        allCCsVector(ccIndex:(ccIndex + numCC - 1)) = ccs(:);
        ccIndex = ccIndex + numCC;
    end
    % Remove isNaNs which may be present for intentionally non-computed values
    % (they're not simply left out of the matrices for reasons related to index-based logic)
    allCCsVector = allCCsVector(~isnan(allCCsVector));
    meanCC = mean(allCCsVector);
    stdCC = std(allCCsVector);
end