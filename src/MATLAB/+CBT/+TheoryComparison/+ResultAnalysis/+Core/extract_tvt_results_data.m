function [bestCCsRaw, theoryDataHashesRaw, theoryNamesRaw, theoryLengths_bpRaw] = extract_tvt_results_data(resultsStructTvT)
    import Fancy.Utils.extract_fields;
    [bestCCsRaw, theoryDataHashesRaw, theoryNamesRaw, theoryLengths_bpRaw] = extract_fields(resultsStructTvT,...
        {'bestCC'; 'theoryDataHashes'; 'theoryNames'; 'theoryLengths_bp'});
    theoryLengths_bpRaw = cell2mat(theoryLengths_bpRaw);
end