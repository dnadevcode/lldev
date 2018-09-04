function [expCurveBitmask] = get_experiment_bitmask(experimentStruct, deltaCut, psfSigmaWidth_nm, pixelWidth_nm)
    if isfield(experimentStruct, 'experimentCurveBitmask_pxRes')
        expCurveBitmask = experimentStruct.experimentCurveBitmask_pxRes;
    else
        import CBT.TheoryComparison.get_struct_experiment_curve_pxRes;
        experimentCurve_pxRes = get_struct_experiment_curve_pxRes(experimentStruct);
        curveLen = length(experimentCurve_pxRes);

        import CBT.TheoryComparison.get_std_experiment_bitmask;
        expCurveBitmask = get_std_experiment_bitmask(curveLen, deltaCut, psfSigmaWidth_nm, pixelWidth_nm);
    end
end