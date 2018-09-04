function f_rI = get_f_rI(max_rI)
    import Fancy.AppMgr.AppResourceMgr;
    dataCacheDirpath = AppResourceMgr.get_dirpath('DataCache');
    cacheFilename = 'f_rI_cache.mat';
    cacheFilepath = fullfile(dataCacheDirpath, 'CBT', 'TheoryComparison', 'PValue', cacheFilename);
        
    z = -10:0.01:10;
    expression1 = (1 + erf(z))/2;
    expression2 = z.*exp(-z.^2);
    expression3 = 2/sqrt(2*pi);
    f_rI = NaN(1, 0);
    try
        f_rI = feval(@(s) s.f_rI, load(cacheFilepath, 'f_rI'));
    catch
    end
    if length(f_rI) < max_rI % not loaded from cache
        f_rI = [f_rI, arrayfun(@(rI) expression3*rI*trapz(z, expression2.*power(expression1, rI - 1)), (length(f_rI) + 1):max_rI)];
        save(cacheFilepath, 'f_rI'); % update cache file
    end
    f_rI = f_rI(1:max_rI);
end