function [] = export_matches_as_tsv(tsvFilepath, theoryNames, outlierScoresMatrix, matchMatrix)
    import Fancy.IO.TSV.write_tsv;

    matSize = size(matchMatrix);
    matchIndices = find(matchMatrix);
    
    [sparseMatchesA, sparseMatchesB] = ind2sub(matSize, matchIndices);
    sparseMatches = arrayfun(@(i) theoryNames{i}, [sparseMatchesA, sparseMatchesB], 'UniformOutput', false);

    sMatches.oValues = outlierScoresMatrix(matchIndices);
    sMatches.theoryA = sparseMatches(:,1);
    sMatches.theoryB = sparseMatches(:,2);
    write_tsv(tsvFilepath, sMatches, fields(sMatches));
end