function [bsosStruct, cache, cacheKey, resultFromCache] = get_best_synced_orientation_similarity(circSeqA, circSeqB, indexWeightsA, indexWeightsB, cache)
    import CBT.Consensus.Caching.check_cache_for_best_synced_orientation_similarity;
    import CBT.Consensus.Core.calc_best_synced_orientation_similarity;

    [resultFromCache, cacheKey, bsosStruct] = check_cache_for_best_synced_orientation_similarity(circSeqA, circSeqB, indexWeightsA, indexWeightsB, cache);
    if not(resultFromCache)
        bsosStruct = calc_best_synced_orientation_similarity(circSeqA, circSeqB, indexWeightsA, indexWeightsB);
        cache(cacheKey) = bsosStruct;
    end
end