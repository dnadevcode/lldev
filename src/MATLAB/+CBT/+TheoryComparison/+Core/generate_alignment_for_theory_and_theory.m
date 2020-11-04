function [alignedThyCurveA, alignedThyCurveB,...
        alignedThyCurveABitmask, alignedThyCurveBBitmask,...
        alignedThyCurveAIndices, alignedThyCurveBIndices,...
        thyCurveA_pxRes, thyCurveB_pxRes]...
        = generate_alignment_for_theory_and_theory(theoryStructA, theoryStructB, stretchFactor, constantSettingsStruct)
    import Fancy.Utils.extract_fields;
    [...
        deltaCut,...
        psfSigmaWidth_nm,...
        psfSigmaWidth_bp,...
        pixelWidth_nm,...
        pixelsPerBp...
        ] = extract_fields(constantSettingsStruct, {
            'deltaCut',...
            'psfWidth_nm',...
            'psfWidth_bp',...
            'nmPerPixel',...
            'pixelsPerBp'...
            });

    import CBT.TheoryComparison.get_struct_theory_curve_bpRes;
    thyCurveA_bpRes = get_struct_theory_curve_bpRes(theoryStructA,1);


    if isempty(thyCurveA_bpRes)
        error('Theory curve is empty or could not be loaded from cache filepath');
    end

    % Stretch/compress based on stretch factor
    import CBT.Core.apply_stretching;
    thyCurveA_bpRes = apply_stretching(thyCurveA_bpRes, stretchFactor);

    % Smooth in basepair resolution by convolving curve with PSF
    import Microscopy.Simulate.Core.apply_point_spread_function;
    thyCurveA_bpRes = apply_point_spread_function(thyCurveA_bpRes, psfSigmaWidth_bp);

    % Convert to pixel resolution (and also reisner-rescale)
    import CBT.Core.convert_bpRes_to_pxRes;
    thyCurveA_pxRes = convert_bpRes_to_pxRes(thyCurveA_bpRes, pixelsPerBp);
    thyCurveA_pxRes = zscore(thyCurveA_pxRes);

    % compute best Pearson cross-correlation coefficient & alignment:
    thyCurveABitmask = true(size(thyCurveA_pxRes));

    thyCurveB_bpRes = get_struct_theory_curve_bpRes(theoryStructB,1);


    if isempty(thyCurveB_bpRes)
        error('Theory curve is empty or could not be loaded from cache filepath');
    end

    % Smooth in basepair resolution by convolving curve with PSF
    thyCurveB_bpRes = apply_point_spread_function(thyCurveB_bpRes, psfSigmaWidth_bp);

    % Convert to pixel resolution (and also reisner-rescale)
    thyCurveB_pxRes = convert_bpRes_to_pxRes(thyCurveB_bpRes, pixelsPerBp);
    thyCurveB_pxRes = zscore(thyCurveB_pxRes);

    import CBT.TheoryComparison.Core.get_theory_bitmask;
    thyCurveBBitmask = get_theory_bitmask(thyCurveB_pxRes, true, deltaCut, psfSigmaWidth_nm, pixelWidth_nm); % get bitmask as if experiment

    import SignalRegistration.XcorrAlign.find_best_alignment_params;
    [thyCurveBIndicesAtBestN, thyCurveAIndicesAtBestN] = find_best_alignment_params(...
        thyCurveB_pxRes, thyCurveA_pxRes, thyCurveBBitmask, thyCurveABitmask, false, true); % lin_circ
    % note: although XcorrAlign calculates the best by a weighted score that takes into account the coverage length,
    %   so long as the circular bitmask is all 1s and the linear curve cannot be cropped any shorter than it already is (or the circular sequence is)
    %   the coverage length will remain constant, so the best cross-correlation coefficient should always be present at the highest score
    % XcorrAlign and Xcorr contain all the new bitmask correlation code and are in the svn if you want a closer look
    alignedThyCurveAIndices = thyCurveAIndicesAtBestN{1};
    alignedThyCurveBIndices = thyCurveBIndicesAtBestN{1};

    alignedThyCurveA = thyCurveA_pxRes(alignedThyCurveAIndices);
    alignedThyCurveABitmask = thyCurveABitmask(alignedThyCurveAIndices);
    alignedThyCurveB = thyCurveB_pxRes(alignedThyCurveBIndices);
    alignedThyCurveBBitmask = thyCurveBBitmask(alignedThyCurveBIndices);

    alignedThyCurveA = alignedThyCurveA(:)';
    alignedThyCurveB = alignedThyCurveB(:)';
    alignedThyCurveABitmask = alignedThyCurveABitmask(:)';
    alignedThyCurveBBitmask = alignedThyCurveBBitmask(:)';
    alignedThyCurveAIndices = alignedThyCurveAIndices(:)';
    alignedThyCurveBIndices = alignedThyCurveBIndices(:)';
    thyCurveA_pxRes = thyCurveA_pxRes(:)';
    thyCurveB_pxRes = thyCurveB_pxRes(:)';
end