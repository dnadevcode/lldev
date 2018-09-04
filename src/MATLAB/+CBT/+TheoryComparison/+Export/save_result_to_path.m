function [] = save_result_to_path(cacheResultsSubfolderPath, resultsStruct)
    aHash = resultsStruct.structA.dataHash;
    bHash = resultsStruct.structB.dataHash;
    resultsFilepath = fullfile(cacheResultsSubfolderPath, [aHash, '-', bHash, '.mat']);
    if not(exist(resultsFilepath, 'file'))
        save(resultsFilepath, 'resultsStruct');
    end
end