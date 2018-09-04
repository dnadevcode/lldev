function [found, resultsStruct] = load_result_from_path(cacheResultsSubfolderPath, structA, structB)
    found = false;
    resultsStruct = [];
    aHash = structA.dataHash;
    bHash = structB.dataHash;
    resultsFilepath = [cacheResultsSubfolderPath, aHash, '-', bHash, '.mat'];
    if exist(resultsFilepath, 'file')
        resultsStruct = load(resultsFilepath, 'resultsStruct');
        if isstruct(resultsStruct) && isfield(resultsStruct, 'resultsStruct')
            resultsStruct = resultsStruct.resultsStruct;
        end
    end
    if not(isempty(resultsStruct)) && isstruct(resultsStruct)
        found = true;
    end
end