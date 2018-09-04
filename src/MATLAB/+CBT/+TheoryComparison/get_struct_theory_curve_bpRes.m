function theoryCurve_bpRes = get_struct_theory_curve_bpRes(theoryStruct)
    theoryCurve_bpRes = [];
    if isfield(theoryStruct, 'theoryCurve_bpRes_prePSF')
        theoryCurve_bpRes = theoryStruct.theoryCurve_bpRes_prePSF;
        return;
    end
    if (isfield(theoryStruct, 'cacheFilepath') && exist(theoryStruct.cacheFilepath, 'file'))
        loaded = load(theoryStruct.cacheFilepath, 'cacheStruct');
        cacheStruct = loaded.cacheStruct;
        if isfield(cacheStruct, 'rawIntensityCurve')
            theoryCurve_bpRes = cacheStruct.rawIntensityCurve;
            return;
        end
    end
end