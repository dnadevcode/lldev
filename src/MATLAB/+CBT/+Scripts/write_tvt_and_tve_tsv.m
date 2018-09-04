function write_tvt_and_tve_tsv(tvtPath, expMatpath, isConsensus, myTheoryName, mergeDuplicates)
    %fka write_the_tsv

    import Fancy.IO.TSV.write_tsv;
    
    tvt = load(tvtPath);
	[dirpath, filename] = fileparts(expMatpath);
	tve = load(expMatpath);
	tve.theoryNames = cellfun(@(x) strrep(strrep(x, '.1', ''), '.2', ''), tve.theoryNames, 'UniformOutput', false);
	notFoundBitmask = cellfun(@(t) isempty(find(strcmp(tvt.theoryNames, t), 1, 'first')), tve.theoryNames);
	foundBitmask = ~notFoundBitmask;
	myTheoryName_tvtIndex = find(strcmp(tvt.theoryNames, myTheoryName), 1, 'first');
	comparisonTheories_tvtIndices = cellfun(@(x) find(strcmp(tvt.theoryNames, x), 1, 'first'), tve.theoryNames(foundBitmask));
	s.theoryNames = tve.theoryNames(foundBitmask);
	s.theoryLengths = tvt.theoryLengths_bp(comparisonTheories_tvtIndices);
	s.theoryDataHashes = tvt.theoryDataHashes(comparisonTheories_tvtIndices);
	s.bestCC_tvt = tvt.bestCC(comparisonTheories_tvtIndices, myTheoryName_tvtIndex);

	if mergeDuplicates
		[~, uniqueThyIdxs] = unique(s.theoryDataHashes,'stable');
		s.theoryNames = arrayfun(@(i) strjoin(s.theoryNames(strcmp(s.theoryDataHashes, s.theoryDataHashes{i})),'/'), uniqueThyIdxs, 'UniformOutput', false);
		s.bestCC_tvt = s.bestCC_tvt(uniqueThyIdxs);
		s.theoryLengths = s.theoryLengths(uniqueThyIdxs);
		s.theoryDataHashes = s.theoryDataHashes(uniqueThyIdxs);
	end

	numExperiments = length(tve.experimentNames);
	expNames = arrayfun(@(k) matlab.lang.makeValidName(strrep(strrep(tve.experimentNames{k}, '.mat', ''),'.tif','')), 1:numExperiments, 'UniformOutput', false);
    if isConsensus 
		tveFieldNames = strcat({'bestCC_tvc_'}, expNames(:));
	else
		tveFieldNames = strcat({'bestCC_tve_'}, expNames(:));
    end
    for experimentNum=1:numExperiments
		bestCC_tve = tve.bestCC(foundBitmask, experimentNum);
        if mergeDuplicates
            bestCC_tve = bestCC_tve(uniqueThyIdxs);
        end
		s.(tveFieldNames{experimentNum}) = bestCC_tve;
    end
    if mergeDuplicates
        filename = sprintf('dupesmerged_%s', filename);
    end
    tsvFilepath = fullfile(dirpath, [filename, '.tsv']);
    fprintf('Writing to ''%s''...\n', tsvFilepath);
	write_tsv(tsvFilepath, s, [{'theoryNames'; 'theoryDataHashes'; 'theoryLengths'; 'bestCC_tvt'}; tveFieldNames(:)]);
end