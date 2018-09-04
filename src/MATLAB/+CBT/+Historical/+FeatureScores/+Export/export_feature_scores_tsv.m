function [] = export_feature_scores_tsv(featureScoresStruct, tsvFilepath)
    if nargin < 2
        [tsvFilename, tsvDirpath] = uiputfile({'.tsv'});
        if isequal(tsvDirpath, 0)
            return;
        end
        tsvFilepath = fullfile(tsvDirpath, tsvFilename);
    end

    columnNames = {'Name', 'Feature Score', 'Feature Score Density', 'Length (bp)'};
    columnFields = {'displayNames', 'featureScores', 'featureScoreDensities', 'sequenceLengths'};
    import Fancy.IO.TSV.write_tsv;
    write_tsv(tsvFilepath, featureScoresStruct, columnFields, columnNames);
end