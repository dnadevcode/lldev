function experimentCurve_pxRes = get_struct_experiment_curve_pxRes(experimentStruct)
    experimentCurve_pxRes = [];
    if isfield(experimentStruct, 'experimentCurve_pxRes')
        experimentCurve_pxRes = experimentStruct.experimentCurve_pxRes;
    end
end