function [] = export_bestCC_thresholds_for_alphas_as_tsv(alphas, tvtResultsFilepath, tsvFilepath)
    import Fancy.UI.FancyInput.smart_input_dlg;
	import Fancy.Validation.generate_validator;
    import Fancy.IO.TSV.write_tsv;
    import Fancy.Utils.extract_fields;
    import GumbelAnalysis.Core.compute_threshold_from_outlier_score;
    import GumbelAnalysis.Core.get_matches;
    import CBT.TheoryComparison.ResultAnalysis.Import.prompt_filepaths_for_tvt_results;
    import CBT.TheoryComparison.ResultAnalysis.UI.prompt_indices_range;
    import CBT.TheoryComparison.ResultAnalysis.UI.prompt_should_merge_duplicates;
    
    if nargin < 1
        defaultAlphas = 0.0005;
        defaultAlphasStr = strjoin(arrayfun(@num2str, defaultAlphas, 'UniformOutput', false), ', ');
        alphasValidator = generate_validator({'row', 'nonempty', {'>', 0}, {'<', 1}});
        [aborted, convertedValues] = smart_input_dlg(...
            {defaultAlphasStr}, {'alphas (comma separated)'}, 'Select alphas', [],...
            {alphasValidator}, {@(s) str2double(strsplit(s,','))}, [], [], []);
        if aborted
            return;
        end
        alphas = convertedValues{1};
    end
    
    if nargin < 2
        tvtResultsFilepath = '';
    end
    
    if nargin < 3
        tsvFilepath = '';
    end

    
    if isempty(tvtResultsFilepath)
        [aborted, filepaths] = prompt_filepaths_for_tvt_results(false);
        if aborted
            return;
        end
        tvtResultsFilepath = filepaths{1};
    end
    
    if isempty(tsvFilepath)
        timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        defaultTsvDirpath = appDirpath;
        defaultTsvFilename = sprintf('Alphas_BestCC_Thresholds_%s.tsv', timestamp);
        defaultTsvFilepath = fullfile(defaultTsvDirpath, defaultTsvFilename);
        [tsvFilename, tsvDirpath, ~] = uiputfile('*.tsv', 'Save Alpha''s BestCC Thresholds As', defaultTsvFilepath);
        tsvFilepath = fullfile(tsvDirpath, tsvFilename);
    end
    
    mergeDuplicates = prompt_should_merge_duplicates();
    
    resultsStructTvT = load(tvtResultsFilepath);
    [bestCCsRaw, theoryDataHashesRaw, theoryNamesRaw, theoryLengths_bpRaw] = extract_fields(resultsStructTvT,...
        {'bestCC'; 'theoryDataHashes'; 'theoryNames'; 'theoryLengths_bp'});
    
    if mergeDuplicates
        [~, ui] = unique(theoryDataHashesRaw,'stable');
        theoryNames = arrayfun(@(i) strjoin(theoryNamesRaw(strcmp(theoryDataHashesRaw, theoryDataHashesRaw{i})),'/'), ui, 'UniformOutput', false);
        bestCCs = bestCCsRaw(ui, ui);
        theoryLengths_bp = theoryLengths_bpRaw(ui);
        theoryDataHashes = theoryDataHashesRaw(ui);
    else
        theoryNames = theoryNamesRaw;
        bestCCs = bestCCsRaw;
        theoryLengths_bp = theoryLengths_bpRaw;
        theoryDataHashes = theoryDataHashesRaw;
    end

    indicesToInclude = prompt_indices_range(theoryLengths_bp);
    theoryNames = theoryNames(indicesToInclude);
    bestCCs = bestCCs(indicesToInclude, indicesToInclude);
    theoryLengths_bp = theoryLengths_bp(indicesToInclude);
    theoryDataHashes = theoryDataHashes(indicesToInclude);
    
    s.theoryNames = theoryNames;
    s.theoryDataHashes = theoryDataHashes;
    s.theoryLengths_bp = theoryLengths_bp;


    numAlphas = length(alphas);
    for alphaNum=1:numAlphas
        alpha = alphas(alphaNum);
        alphaStr = num2str(alpha);
        fprintf('Recursive Gumbel-fitting with alpha %g\n', alpha);
        [~, ~, gumbelCurveMusByIteration, gumbelCurveBetasByIteration] = get_matches(alpha, bestCCs, 2);

        gumbelCurveBetasRecursive = gumbelCurveBetasByIteration{end};
        gumbelCurveMusRecursive = gumbelCurveMusByIteration{end};

        fieldname = sprintf('bestCC_threshold_alpha_%s', strrep(alphaStr,'.', '_'));
        s.(fieldname) = arrayfun(...
            @(gumbelCurveMu, gumbelCurveBeta) ...
                compute_threshold_from_outlier_score(alpha, gumbelCurveMu, gumbelCurveBeta), ...
                gumbelCurveMusRecursive(:), gumbelCurveBetasRecursive(:));
    end

    
    fprintf('Writing results to %s\n', tsvFilepath);
    write_tsv(tsvFilepath, s, fields(s));
end