function make_main_theory_comparison_ui(ts)
    ctrlStruct.loadedData.theoriesFromDisplayName = containers.Map('KeyType', 'char', 'ValueType', 'any');
    ctrlStruct.loadedData.theories = containers.Map('KeyType', 'char', 'ValueType', 'any');
    ctrlStruct.loadedData.experiments = containers.Map('KeyType', 'char', 'ValueType', 'any');

    settingsStruct = struct;

    cacheExists = false;
    cacheSubfolderPath = '';
    cacheResultsSubfolderPath = '';
    lastPercentageProgress = 0;
    PercentageProgressInterval = 0.05;

    function on_params_ready(paramsStruct)
    
        if paramsStruct.checkCacheForIntensityCurves
           envConstantsStruct = struct('NETROPSINconc', paramsStruct.NETROPSINconc, 'YOYO1conc', paramsStruct.YOYO1conc);
           settingsStruct.constants = paramsStruct;
           [cacheExists, cacheSubfolderPath] = has_cache(envConstantsStruct);

            constSettings = settingsStruct.constants;
            settingsParams = settingsStruct.constants; %#ok<NASGU>
            assignin('base', 'settingsParams', constSettings);
            maxPairLengthDiffRelative = constSettings.maxPairLengthDiffRelative;
            maxPairLengthDiffAbsolute_nm = constSettings.maxPairLengthDiffAbsolute_nm;
            constSettings = rmfield(constSettings, 'maxPairLengthDiffRelative');
            constSettings = rmfield(constSettings, 'maxPairLengthDiffAbsolute_nm');
            
            import Fancy.Utils.data_hash;
            settingsHash = data_hash(constSettings);
            constSettings.maxPairLengthDiffRelative = maxPairLengthDiffRelative;
            constSettings.maxPairLengthDiffAbsolute_nm = maxPairLengthDiffAbsolute_nm;
            cacheResultsSubfolderPath = [cacheSubfolderPath, filesep, '_R_', settingsHash, filesep];
            
            import Fancy.IO.mkdirp;
            mkdirp(cacheResultsSubfolderPath);
            cacheResultsMainFilepath = [cacheResultsSubfolderPath, '_settingsParams.mat'];
            if not(exist(cacheResultsMainFilepath, 'file'))
                save(cacheResultsMainFilepath, 'settingsParams');
            end
        end
        import CBT.TheoryComparison.UI.launch_theory_import_ui;
        launch_theory_import_ui(ctrlStruct, ts, @already_have_theory_loaded, @on_theories_load_completion, @on_theory_load_start, @on_theory_load_end, @on_compare_theories_vs_theories, @on_load_experiment_curves);
    end
    import CBT.TheoryComparison.UI.get_parameters_ui;
    get_parameters_ui(ts, @on_params_ready);


    function tf = already_have_theory_loaded(displayName, sourceFilepath)
        if isKey(ctrlStruct.loadedData.theoriesFromDisplayName, displayName)
            theStruct = ctrlStruct.loadedData.theoriesFromDisplayName(displayName);
            if isfield(theStruct, 'sourceFilepath') && strcmp(theStruct.sourceFilepath, sourceFilepath)
                tf = true;
                return;
            end
        end
        tf = false;
        return;
    end

    function [goodCacheExists, cacheSubfolderPath] = has_cache(dataStruct)
        import Fancy.Utils.FancyStrUtils.str_ends_with;
        import Fancy.Utils.data_hash;
        
        paramHash = data_hash(dataStruct);
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        defaultDirpath = fullfile(appDirpath, 'OutputFiles', 'Cache', 'IntensityCurves');
        dirpath = uigetdir(defaultDirpath, 'Select the IntensityCurves Cache Directory');
        if isequal(dirpath, 0)
           error('Cache directory must be selected!');
        end
        if (dirpath(end) ~= filesep)
            dirpath = [dirpath, filesep];
        end

        if not(str_ends_with(dirpath, [filesep, 'IntensityCurves', filesep]))
            error('The cache directory is expected to be named ''IntensityCurves''');
        end
        cacheSubfolderPath = [dirpath, paramHash, filesep];

        goodCacheExists = (exist(cacheSubfolderPath, 'dir') ~= 0);
    end

    function on_load_experiment_curves(ts, theoryDisplayNames)
        import CBT.TheoryComparison.UI.launch_experiment_curve_import_ui;
        launch_experiment_curve_import_ui(ts, theoryDisplayNames, @on_compare_theories_vs_experiments);
    end


    function on_compare_theories_vs_theories(ts, theoryNamesA, theoryNamesB)
        import CBT.TheoryComparison.go_compare_theories_vs_theories;

        theoriesFromDisplayName = ctrlStruct.loadedData.theoriesFromDisplayName;
        constSettings = settingsStruct.constants;
        go_compare_theories_vs_theories(ts, theoriesFromDisplayName, theoryNamesA, theoryNamesB, constSettings, cacheResultsSubfolderPath);
    end

    function on_compare_theories_vs_experiments(ts, experimentNames, experimentCurveStructs, theoryNames)

        [theoryNames, theoryStructs] = get_length_ordered_theory_structs(theoryNames);
        assignin('base', 'theoryNames', theoryNames);
        assignin('base', 'theoryStructs', theoryStructs);
        
        
        numExperimentCurves = length(experimentNames);
        for experimentNum=1:numExperimentCurves
            ctrlStruct.loadedData.experiments(experimentNames{experimentNum}) = experimentCurveStructs{experimentNum};
        end

        
        [experimentNames, experimentStructs] = get_length_ordered_experiment_structs(experimentNames);
        
        assignin('base', 'experimentNames', experimentNames);
        assignin('base', 'experimentStructs', experimentStructs);
        
        constSettings = settingsStruct.constants;
    
        import CBT.TheoryComparison.go_compare_theories_vs_experiments;
        go_compare_theories_vs_experiments(ts, theoryStructs, experimentStructs, constSettings, cacheResultsSubfolderPath);
    end

    function [theoryNames, theoryStructs] = get_length_ordered_theory_structs(theoryNames)
        % returns theory structs ordered by length
        
        theoriesFromDisplayName = ctrlStruct.loadedData.theoriesFromDisplayName;
        
        numTheories = length(theoryNames);
        theoryStructs = cell(numTheories, 1);
        for theoryNum = 1:numTheories
            theoryDisplayName = theoryNames{theoryNum};
            theoryStruct = theoriesFromDisplayName(theoryDisplayName);
            theoryStructs{theoryNum} = theoryStruct;
        end
        
        constSettings = settingsStruct.constants;
        import CBT.TheoryComparison.Core.get_length_ordering_for_theories;
        [~, orderedTheoryIndices] = get_length_ordering_for_theories(theoryStructs, constSettings.nmPerBp);
        theoryNames = theoryNames(orderedTheoryIndices);
        theoryStructs = theoryStructs(orderedTheoryIndices);
    end

    function [experimentNames, experimentStructs] = get_length_ordered_experiment_structs(experimentNames, experimentsFromDisplayName)
        experimentsFromDisplayName = ctrlStruct.loadedData.experiments;
        
        numExperiments = length(experimentNames);
        experimentStructs = cell(numExperiments, 1);
        for experimentNum = 1:numExperiments
            experimentName = experimentNames{experimentNum};
            experimentStruct = experimentsFromDisplayName(experimentName);
            experimentStructs{experimentNum} = experimentStruct;
        end
        import CBT.TheoryComparison.Core.get_length_ordering_for_experiments;
        constSettings = settingsStruct.constants;
        [~, orderedExperimentIndices] = get_length_ordering_for_experiments(experimentStructs, constSettings.nmPerPixel);
        experimentNames = experimentNames(orderedExperimentIndices);
        experimentStructs = experimentStructs(orderedExperimentIndices);
    end

    function on_theories_load_completion(err, ~)
        if (err)
            error('Failed to load theories/generate curves');
        end

        disp('Successfully finished loading theory sequences and generating theory curves!');
        theoriesFromDisplayName = ctrlStruct.loadedData.theoriesFromDisplayName;
        theoryNames = keys(theoriesFromDisplayName);
        numTheories = length(theoryNames);
        for theoryNum=1:numTheories
            theoryDisplayName = theoryNames{theoryNum};
            theoryDisplayNameStruct = theoriesFromDisplayName(theoryDisplayName);
            disp(theoryDisplayName);
            fprintf(' Sequence Length: %d\n', theoryDisplayNameStruct.sequenceLength);
        end
    end

    function on_theory_load_start(~, ~)
        % fprintf('Loading theory sequence: %s\n', theoryStruct.displayName);
    end

    function on_theory_load_end(~, theoryStruct, curveNum, numCurves)
        import CBT.TheoryComparison.run_curve_generation;

        if ((curveNum/numCurves) >= lastPercentageProgress + PercentageProgressInterval)
            lastPercentageProgress = (curveNum/numCurves);
            fprintf('%d%% complete\n', floor(lastPercentageProgress * 100));
            if curveNum == numCurves
                lastPercentageProgress = 0;
            end
        end
        displayName = theoryStruct.displayName;
        sourceFilepath = theoryStruct.sourceFilepath;
        sequenceDataHash = theoryStruct.dataHash;
        % fprintf('Done loading theory sequence: %s\n', displayName);
        theoryStruct = run_curve_generation(...
            settingsStruct.constants.NETROPSINconc,...
            settingsStruct.constants.YOYO1conc,...
            settingsStruct.constants.bindingSequence,...
            settingsStruct.constants.saveToCache,...
            theoryStruct, curveNum, numCurves, cacheExists, cacheSubfolderPath);
        ctrlStruct.loadedData.theoriesFromDisplayName(displayName) = struct(...
            'dataHash', sequenceDataHash,...
            'sequenceLength', length(theoryStruct.sequenceData),...
            'sourceFilepath', sourceFilepath,...
            'cacheFilepath', theoryStruct.cacheFilepath...
            );
        ctrlStruct.loadedData.theories(sequenceDataHash) = theoryStruct;
    end

end