function [] = write_values_to_file(matrix, theoryIndices, theoryNames, dataLabel, removeNaNs)
    import Fancy.IO.TSV.write_tsv;

    if nargin < 5
        removeNaNs = true;
    end

    numTheoriesToWrite = length(theoryNames);
    for theoryToWriteNum=1:numTheoriesToWrite
        theoryIndex = theoryIndices(theoryToWriteNum);
        theoryName = theoryNames{theoryToWriteNum};
        values = matrix(theoryIndex,:);
        if removeNaNs
            values = values(not(isnan(values)));
        end

        [tsvFilename, tsvDirpath] = uiputfile({[dataLabel, ' - ', theoryName, '.tsv']});

        if isequal(tsvDirpath, 0)
            continue;
        end
        tsvFilepath = [tsvDirpath, tsvFilename];

        structField = matlab.lang.makeValidName(dataLabel);
        write_tsv(tsvFilepath, struct(structField, values), {structField}, {dataLabel});
    end
end