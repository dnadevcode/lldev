function [theoryStructs] = load_structs_from_paths(theorySequenceFilepaths, permanentCurvesDirpath, cacheSubdirname, cacheResultsSubdirname)
    import CBT.TheoryComparison.ClusterComputing.load_struct_from_path;

    numTheories = length(theorySequenceFilepaths);
    theoryStructs = cell(numTheories, 1);
    fprintf('Loading theories into structs...\n');
    tstart = tic;
    percentCompleteBefore = 0;
    for theoryNum=1:numTheories
        percentComplete = floor(100*theoryNum/numTheories);
        if (percentComplete > percentCompleteBefore) && (mod(percentComplete, 5) == 0)
            fprintf('%g%% complete\n', floor(100*theoryNum/numTheories));
            toc(tstart);
        end
        percentCompleteBefore = percentComplete;
        theorySequenceFilepath = theorySequenceFilepaths{theoryNum};
        theoryStructs{theoryNum} = load_struct_from_path(theorySequenceFilepath, permanentCurvesDirpath, cacheSubdirname, cacheResultsSubdirname);
    end
    tmp = cellfun(@(x) x.sequenceLength, theoryStructs);
    [~, ordering] = sort(tmp);
    theoryStructs = theoryStructs(ordering);
    fprintf('Done\n');
    toc(tstart);
end