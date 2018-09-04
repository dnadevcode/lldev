function experimentLength_nm = get_experiment_length(experimentStruct, pixelWidth_nm)
    experimentLength_nm = length(experimentStruct.experimentCurve_pxRes) * pixelWidth_nm;
end