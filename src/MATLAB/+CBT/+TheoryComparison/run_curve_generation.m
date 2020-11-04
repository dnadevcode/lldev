function [theoryStruct] = run_curve_generation(concNetropsin_molar, concYOYO1_molar, bindingSequence, saveToCache, theoryStruct, curveNum, numCurves, cacheExists, cacheSubfolderPath)
    cacheFilepath = '';
    envConstantsStruct = struct('NETROPSINconc', concNetropsin_molar, 'YOYO1conc', concYOYO1_molar);
    if saveToCache
        if isempty(cacheSubfolderPath)
            defaultDirpath = fullfile(pwd(), 'OutputFiles', 'Cache', 'IntensityCurves');
            pathname = uigetdir(defaultDirpath, 'Select the IntensityCurves Cache folder');
            if isequal(pathname, 0)
               disp('Cache folder was not selected');
               saveToCache = false;
            end

            if (pathname(end) ~= filesep)
                pathname = [pathname, filesep];
            end
            import Fancy.Utils.data_hash;
            paramHash = data_hash(envConstantsStruct);
            cacheSubfolderPath = [pathname, paramHash, filesep];
        end
        import Fancy.IO.mkdirp;
        mkdirp(cacheSubfolderPath);
    end

    displayName = theoryStruct.displayName;
    theorySequence = theoryStruct.sequenceData;
    sequenceDataHash = theoryStruct.dataHash;
    wasFoundInCache = false;
    if (cacheExists)
        import CBT.TheoryComparison.Import.is_cached;
        [wasFoundInCache, cachedVal, cacheFilepath] = is_cached(cacheSubfolderPath, sequenceDataHash, displayName, concNetropsin_molar, concYOYO1_molar,bindingSequence);
    end
    if (wasFoundInCache)
        % fprintf('Found curve in cache (%d/%d): %s\n', curveNum, numCurves, displayName);
        theoryCurve_bpRes_prePSF = cachedVal;
    else
        fprintf('Generating intensity curve (%d/%d): %s\n', curveNum, numCurves, displayName);
        
        import CBT.Core.cb_netropsin_vs_yoyo1_plasmid;
        theoryCurve_bpRes_prePSF = cb_netropsin_vs_yoyo1_plasmid(theorySequence, concNetropsin_molar, concYOYO1_molar, [], true);
        
        if ~isequal(bindingSequence,' ')
            import ELT.Core.find_sequence_matches;
            [bindingExpectedMask, numberOfBindings] = find_sequence_matches(bindingSequence, theorySequence);
        else
            bindingExpectedMask = [];
        end
        if saveToCache
            cacheFilepath = [cacheSubfolderPath, sequenceDataHash, '.mat'];
            theoryStruct.cacheFilepath = cacheFilepath;
            
            import CBT.TheoryComparison.Export.save_to_cache;
            save_to_cache(cacheFilepath, concNetropsin_molar, concYOYO1_molar,bindingSequence, sequenceDataHash, displayName, theoryCurve_bpRes_prePSF,bindingExpectedMask);
        end
    end
    if exist(cacheFilepath, 'file')
        theoryStruct.cacheFilepath = cacheFilepath;
    end
    theoryStruct.theoryCurve_bpRes_prePSF = theoryCurve_bpRes_prePSF;
end