function [] = export_tvt_theory_summaries_as_tsvs(resultsStructTvT, thyNames, mergeDuplicates, outputDirpath)
    import Fancy.IO.TSV.write_tsv;
    import Fancy.Utils.extract_fields;

    if nargin < 3
        mergeDuplicates = false;
    end
    if nargin < 4
        import Fancy.AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        outputDirpath = appDirpath;
    end
    
    [bestCCsRaw, theoryDataHashesRaw, theoryNamesRaw, theoryLengths_bpRaw] = extract_fields(...
        resultsStructTvT, ...
        {'bestCC'; 'theoryDataHashes'; 'theoryNames'; 'theoryLengths_bp'});
    thyHashes = theoryDataHashesRaw(cellfun(@(thyName) find(strcmp(thyName, theoryNamesRaw), 1, 'first'), thyNames));


    if mergeDuplicates
        [~, uniqueHashIndices] = unique(theoryDataHashesRaw,'stable');
        theoryNames = arrayfun(@(i) strjoin(theoryNamesRaw(strcmp(theoryDataHashesRaw, theoryDataHashesRaw{i})),'/'), uniqueHashIndices, 'UniformOutput', false);
        bestCCs = bestCCsRaw(uniqueHashIndices, uniqueHashIndices);
        theoryLengths_bp = theoryLengths_bpRaw(uniqueHashIndices);
        theoryDataHashes = theoryDataHashesRaw(uniqueHashIndices);
    else
        theoryNames = theoryNamesRaw;
        bestCCs = bestCCsRaw;
        theoryLengths_bp = theoryLengths_bpRaw;
        theoryDataHashes = theoryDataHashesRaw;
    end

    numTsvs = length(thyHashes);
    tsvFieldsToWrite = {'OtherTheoryName'; 'OtherTheoryHash'; 'OtherTheoryLength'; 'BestCC'};
    tsvColumnNames = {'Other Theory Name'; 'Other Theory Hash'; 'Other Theory Length (bp)'; 'Best CC'};
    thyNames = theoryNames(cellfun(@(thyHash) find(strcmp(thyHash, theoryDataHashes), 1, 'first'), thyHashes));
    tsvFilenames = cellfun(@(thyName) [strrep(thyName, '/', ' - '), '.tsv'], thyNames, 'UniformOutput', false);
    tsvFilepaths = cellfun(@(tsvFilename) fullfile(outputDirpath, tsvFilename), tsvFilenames, 'UniformOutput', false);
    tsvStructs = cell(numTsvs, 1);
    for tsvNum=1:numTsvs
        thyName = thyNames{tsvNum};
        thyIdx = find(strcmp(thyName, theoryNames), 1, 'first');
        thyNonNaNs = not(isnan(bestCCs(thyIdx, :)));
        thyBestCCs = bestCCs(thyIdx, thyNonNaNs);
        thyComparisonHashes = theoryDataHashes(thyNonNaNs);
        thyComparisonNames = theoryNames(thyNonNaNs);
        thyLengths_bp = theoryLengths_bp(thyNonNaNs);
        tsvStruct.(tsvFieldsToWrite{1}) = thyComparisonNames(:);
        tsvStruct.(tsvFieldsToWrite{2}) = thyComparisonHashes(:);
        tsvStruct.(tsvFieldsToWrite{3}) = thyLengths_bp(:);
        tsvStruct.(tsvFieldsToWrite{4}) = thyBestCCs(:);
        tsvStructs{tsvNum} = tsvStruct;
    end
    for tsvNum=1:numTsvs
        tsvStruct = tsvStructs{tsvNum};
        tsvFilepath = tsvFilepaths{tsvNum};
        fprintf('Writing to ''%s''\n', tsvFilepath);
        write_tsv(tsvFilepath, tsvStruct, tsvFieldsToWrite, tsvColumnNames);
    end
end