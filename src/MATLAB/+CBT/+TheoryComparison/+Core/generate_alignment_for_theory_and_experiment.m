function [alignedThyCurve, alignedExperimentCurve,...
        alignedThyCurveBitmask, alignedExperimentCurveBitmask,...
        alignedThyCurveIndices, alignedExperimentCurveIndices,...
        thyCurve_pxRes, experimentCurve_pxRes]...
        = generate_alignment_for_theory_and_experiment(theoryStruct, experimentStruct, stretchFactor, constantSettingsStruct,cb)

    import Fancy.Utils.extract_fields;
    [...
        deltaCut,...
        psfSigmaWidth_nm,...
        psfSigmaWidth_bp,...
        pixelWidth_nm,...
        meanBpExt_pixels...
        ] = extract_fields(constantSettingsStruct, {
            'deltaCut',...
            'psfWidth_nm',...
            'psfWidth_bp',...
            'nmPerPixel',...
            'pixelsPerBp'...
            });

    import CBT.TheoryComparison.get_struct_theory_curve_bpRes;
    thyCurve_bpRes = get_struct_theory_curve_bpRes(theoryStruct,cb);

    if isempty(thyCurve_bpRes)
        error('Theory curve is empty or could not be loaded from cache filepath');
    end

    % Stretch/compress based on stretch factor
    import CBT.Core.apply_stretching;
    thyCurve_bpRes = apply_stretching(thyCurve_bpRes, stretchFactor);

    % Smooth in basepair resolution by convolving curve with PSF
    import Microscopy.Simulate.Core.apply_point_spread_function;
    thyCurve_bpRes = apply_point_spread_function(thyCurve_bpRes, psfSigmaWidth_bp);

    % Convert to pixel resolution (and also reisner-rescale)
    import CBT.Core.convert_bpRes_to_pxRes;
    thyCurve_pxRes = convert_bpRes_to_pxRes(thyCurve_bpRes, meanBpExt_pixels);
    thyCurve_pxRes = zscore(thyCurve_pxRes);

    % compute best Pearson cross-correlation coefficient & alignment:
    thyCurveBitmask = true(size(thyCurve_pxRes));

    import CBT.TheoryComparison.get_struct_experiment_curve_pxRes;
    experimentCurve_pxRes = get_struct_experiment_curve_pxRes(experimentStruct);
    experimentCurve_pxRes = zscore(experimentCurve_pxRes);
    
    import CBT.TheoryComparison.Import.get_experiment_bitmask;
    experimentCurveBitmask = get_experiment_bitmask(experimentStruct, deltaCut, psfSigmaWidth_nm, pixelWidth_nm); % get bitmask as if experiment
    
    import SignalRegistration.XcorrAlign.find_best_alignment_params;
    [exerimentCurveIndicesAtBestN, thyCurveIndicesAtBestN] = find_best_alignment_params(...
        experimentCurve_pxRes, thyCurve_pxRes, experimentCurveBitmask, thyCurveBitmask, false, true); % lin_circ
    % note: although XcorrAlign calculates the best by a weighted score that takes into account the coverage length,
    %   so long as the circular bitmask is all 1s and the linear curve cannot be cropped any shorter than it already is (or the circular sequence is)
    %   the coverage length will remain constant, so the best cross-correlation coefficient should always be present at the highest score
    % XcorrAlign and Xcorr contain all the new bitmask correlation code and are in the svn if you want a closer look
    alignedThyCurveIndices = thyCurveIndicesAtBestN{1};
    alignedExperimentCurveIndices = exerimentCurveIndicesAtBestN{1};

    alignedThyCurve = thyCurve_pxRes(alignedThyCurveIndices);
    alignedThyCurveBitmask = thyCurveBitmask(alignedThyCurveIndices);
    alignedExperimentCurve = experimentCurve_pxRes(alignedExperimentCurveIndices);
    alignedExperimentCurveBitmask = experimentCurveBitmask(alignedExperimentCurveIndices);

    alignedThyCurve = alignedThyCurve(:)';
    alignedExperimentCurve = alignedExperimentCurve(:)';
    alignedThyCurveBitmask = alignedThyCurveBitmask(:)';
    alignedExperimentCurveBitmask = alignedExperimentCurveBitmask(:)';
    alignedThyCurveIndices = alignedThyCurveIndices(:)';
    alignedExperimentCurveIndices = alignedExperimentCurveIndices(:)';
    thyCurve_pxRes = thyCurve_pxRes(:)';
    experimentCurve_pxRes = experimentCurve_pxRes(:)';
end