function [dataFieldMatsStruct, freshlyCalculatedMat, consensusCache] = get_pairwise_values(dataFieldNames, consensusStruct, leafsOnly)
    if nargin < 3
        leafsOnly = true;
    end
    if isfield(consensusStruct, 'cache')
        consensusCache = consensusStruct.cache;
    else
        consensusCache = containers.Map();
    end
    allowRecalculate = true;
    if isempty(consensusCache)
        warning('Cache was not available in consensus so values will be recalculated');
    end
    barcodeKeylist = consensusStruct.keyList;
    if leafsOnly
        barcodeKeylist = barcodeKeylist(1:numel(consensusStruct.inputs.barcodes));
    end
    precalculatedCacheKeys = keys(consensusCache);
    import CBT.Consensus.CoreCacheBridge.get_pairwise_similarities;
    [pairwiseBsos, ~] = get_pairwise_similarities(barcodeKeylist, consensusStruct.barcodeStructsMap, consensusCache, allowRecalculate);

    pairwiseCacheKeys = cellfun(@(bsosStruct) bsosStruct.cacheKey, pairwiseBsos, 'UniformOutput', false);

    freshlyCalculatedMat = cellfun(@(cacheKey) isempty(intersect(precalculatedCacheKeys, {cacheKey})), pairwiseCacheKeys);

    dataFieldNames = intersect(dataFieldNames, {'bestScore'; 'xcorrAtBest'; 'flipTFAtBest'; 'circShiftAtBest'});
    numDataFields = numel(dataFieldNames);
    dataFieldMatsStruct = struct;
    for dataFieldNum=1:numDataFields
        dataFieldName = dataFieldNames{dataFieldNum};
        dataFieldMatsStruct.(dataFieldName) = cellfun(@(s)s.(dataFieldName), pairwiseBsos);
    end
end