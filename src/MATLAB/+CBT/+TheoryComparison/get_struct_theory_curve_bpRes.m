function theoryCurve_bpRes = get_struct_theory_curve_bpRes(theoryStruct,bs)

    if bs==1
        curve = 'rawIntensityCurve';
    else
        curve = 'bindingExpectedMask';      
    end
        
    theoryCurve_bpRes = [];
    if isfield(theoryStruct, 'theoryCurve_bpRes_prePSF')
        theoryCurve_bpRes = theoryStruct.theoryCurve_bpRes_prePSF;
        return;
    end
    if (isfield(theoryStruct, 'cacheFilepath') && exist(theoryStruct.cacheFilepath, 'file'))
        loaded = load(theoryStruct.cacheFilepath, 'cacheStruct');
        cacheStruct = loaded.cacheStruct;
        if isfield(cacheStruct, curve)
            if bs==1
                theoryCurve_bpRes = cacheStruct.rawIntensityCurve;
            else
                theoryCurve_bpRes = double(cacheStruct.bindingExpectedMask);
            end
            return;
        end
    end
end