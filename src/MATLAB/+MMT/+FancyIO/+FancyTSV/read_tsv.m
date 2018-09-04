function dataStruct = read_tsv(filepath, cell2matFields)
    import FancyIO.FancyTSV.unformat_tsv_val;
    
    if nargin < 2
        cell2matFields = {};
    else
        validateattributes(cell2matFields, {'cell'}, {});
        cell2matFields = cell2matFields(:);
    end
    colEndDelim = '\t';
    rowEndDelim = '\n';
    fileID = fopen(filepath, 'r');
    allData = textscan(fileID, '%s', 'Delimiter', {rowEndDelim});
    fclose(fileID);

    allData = allData{1};
    function x = f(x)
        x = strsplit(x, '\t');
    end
    allData = cellfun(@f, allData, 'UniformOutput', false);
    if isempty(allData)
        error('No data');
    end
    structHeaders = allData{1};
    structHeaders = cellfun(@unformat_tsv_val, structHeaders, 'UniformOutput', false);
    if not(iscellstr(structHeaders))
        error('Column headings must be quoted strings');
    end
    numCols = length(structHeaders);
    allData = allData(2:end);
    numRows = length(allData);
    if any(cellfun(@(x) length(x), allData) ~= numCols)
        error('Inconsistent number of entries per row');
    end
    tmp = cell(numRows, numCols);
    for row=1:numRows
        tmp(row, :) = allData{row};
    end
    allData = cellfun(@unformat_tsv_val, tmp, 'UniformOutput', false);
    clear tmp;
    dataStruct = struct;
    for col=1:numCols
        headerName = structHeaders{col};
        colVals = allData(:, col);
        if not(isempty(find(strcmp(headerName, cell2matFields), 1, 'first')))
            colVals = cell2mat(colVals);
        end
        headerName = matlab.lang.makeValidName(headerName);
        dataStruct.(headerName) = colVals;
    end
end