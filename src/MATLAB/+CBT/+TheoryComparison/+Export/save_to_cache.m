function [] = save_to_cache(cacheFilepath, concNetropsin_molar, concYOYO1_molar, sequenceDataHash, displayName, rawIntensityCurve)
    cacheStruct = struct;
    cacheStruct.NETROPSINconc = concNetropsin_molar;
    cacheStruct.YOYO1conc = concYOYO1_molar;
    cacheStruct.sequenceDataHash = sequenceDataHash;
    cacheStruct.displayName = displayName;
    cacheStruct.rawIntensityCurve = rawIntensityCurve; %#ok<STRNU>
    save(cacheFilepath, 'cacheStruct');
end