function [tsvOutputFilepath] = prompt_consensus_ends_tsv_output_filepath()
    defaultDirpath = pwd();
    defaultTsvOutputFilename = 'consensus_ends.tsv';
    defaultTsvOutputFilepath = fullfile(defaultDirpath, defaultTsvOutputFilename);
    [tsvOutputFilename, dirpath] = uiputfile({'*.tsv'}, 'Save consensus end counts as', defaultTsvOutputFilepath);
    if isequal(dirpath, 0)
        tsvOutputFilepath = '';
    else
        tsvOutputFilepath = fullfile(dirpath, tsvOutputFilename);
    end
end