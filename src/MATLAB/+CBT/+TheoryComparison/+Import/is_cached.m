function [wasFoundInCache, cachedVal, cacheFilepath] = is_cached(cacheSubfolderPath, sequenceDataHash, displayName, concNetropsin_molar, concYOYO1_molar,bindingSequence)
    wasFoundInCache = false;
    cachedVal = [];

    if (cacheSubfolderPath(end) ~= filesep)
        cacheSubfolderPath = [cacheSubfolderPath, filesep];
    end
    cacheFilepath = [cacheSubfolderPath, sequenceDataHash, '.mat'];
    if not(exist(cacheFilepath, 'file'))
        % disp('Cached file does not exist');
        return;
    end

    loaded = load(cacheFilepath, 'cacheStruct');
    cacheStruct = loaded.cacheStruct;
    requiredFields = {'NETROPSINconc', 'YOYO1conc', 'bindingSequence', 'sequenceDataHash', 'displayName', 'rawIntensityCurve'};
    numRequiredFields = length(requiredFields);

    if not(isstruct(cacheStruct))
        fprintf('Bad cache for %s (not a struct)', displayName);
        return;
    end

    for requiredFieldNum=1:numRequiredFields
        if not(isfield(cacheStruct, requiredFields{requiredFieldNum}))
           fprintf('Bad cache for %s (missing field: %s)', displayName, requiredFields{requiredFieldNum});
           return;
        end
    end

    if not((cacheStruct.NETROPSINconc == concNetropsin_molar)...
            && (cacheStruct.YOYO1conc == concYOYO1_molar)...
            && (isequal(cacheStruct.bindingSequence,bindingSequence))...
            && strcmp(cacheStruct.sequenceDataHash, sequenceDataHash))
        fprintf('Bad cache for %s-%s (inconsistent values: %s-%s)', displayName, sequenceDataHash, cacheStruct.displayName, cacheStruct.sequenceDataHash);
        return;
    end

    wasFoundInCache = true;
    cachedVal = cacheStruct.rawIntensityCurve;
end