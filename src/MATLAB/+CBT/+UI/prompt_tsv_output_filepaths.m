function [tsvFilepaths] = prompt_tsv_output_filepaths(ntSeqFilepaths, theoryNames)
    numTheories = length(ntSeqFilepaths);
    tsvFilepaths = cell(numTheories,1);
    for theoryNum = 1:numTheories
        ntSeqFilepath = ntSeqFilepaths{theoryNum};
        defaultTsvDirpath = fileparts(ntSeqFilepath);

        theoryName = theoryNames{theoryNum};
        defaultTsvFilename = sprintf('%s_cbt_curve_pxRes.tsv', theoryName);
        defaultTsvFilepath = fullfile(defaultTsvDirpath, defaultTsvFilename);
        [tsvFilename, tsvDirpath] = uiputfile('*.tsv', 'Save Curve As', defaultTsvFilepath);
        tsvSelectionAborted = isequal(tsvDirpath, 0);
        if tsvSelectionAborted
            continue;
        end
        tsvFilepath = fullfile(tsvDirpath, tsvFilename);
        tsvFilepaths{theoryNum} = tsvFilepath;
    end
end