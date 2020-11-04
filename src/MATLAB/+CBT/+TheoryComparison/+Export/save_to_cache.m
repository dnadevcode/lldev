function [] = save_to_cache(cacheFilepath, concNetropsin_molar, concYOYO1_molar, bindingSequence,sequenceDataHash, displayName, rawIntensityCurve,bindingExpectedMask)
    cacheStruct = struct;
    cacheStruct.NETROPSINconc = concNetropsin_molar;
    cacheStruct.YOYO1conc = concYOYO1_molar;
    cacheStruct.sequenceDataHash = sequenceDataHash;
    cacheStruct.displayName = displayName;
    cacheStruct.bindingSequence = bindingSequence;
    cacheStruct.rawIntensityCurve = rawIntensityCurve; %#ok<STRNU>
    cacheStruct.bindingExpectedMask = bindingExpectedMask; %#ok<STRNU>

    save(cacheFilepath, 'cacheStruct');
end