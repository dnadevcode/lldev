function [tableData, tableColMetadata] = sql_result_set_to_matlab_data_table(rsQuery)
    rsMetaDataQuery = rsQuery.getMetaData();

    numCols = rsMetaDataQuery.getColumnCount();

    % http://docs.oracle.com/javase/7/docs/api/java/sql/ResultSetMetaData.html
    column_name = cell(numCols, 1);
    column_label = cell(numCols, 1);
    column_type_name = cell(numCols, 1);
    column_class_name = cell(numCols, 1);
    % colDisplaySizes = cell(colCount, 1);
    for colIdx = 1:numCols
        column_name{colIdx} = char(rsMetaDataQuery.getColumnName(colIdx)); % column's name
        column_label{colIdx} = char(rsMetaDataQuery.getColumnLabel(colIdx)); % column's suggested title for use in printouts and displays
        column_type_name{colIdx} = char(rsMetaDataQuery.getColumnTypeName(colIdx)); % column's database-specific type name
        column_class_name{colIdx} = char(rsMetaDataQuery.getColumnClassName(colIdx).toString());% Java class whose instances are manufactured if the method ResultSet.getObject
        % colDisplaySizes{colIdx} = rsMetaDataQueryCols.getColumnDisplaySize(colIdx);
    end
    
    tableColMetadata = table(column_name, column_label, column_type_name, column_class_name);


    tableData = containers.Map('KeyType', 'uint64', 'ValueType', 'any');

    colLabelsValidified =  cellfun(@matlab.lang.makeValidName, column_label(:), 'UniformOutput', false);

    rowIdx = 1;
    while rsQuery.next()
        rowStruct = struct();
        for colIdx = 1:numCols
            colLabel = column_label{colIdx};
            colLabelValidified = colLabelsValidified{colIdx};
            val = rsQuery.getObject(colLabel);
            rowStruct.(colLabelValidified) = val;
        end
        tableData(uint64(rowIdx)) = rowStruct;
        rowIdx = rowIdx + 1;
    end
    rowIdxs = cellfun(@(x) x, tableData.keys());
    rowIdxs = sort(rowIdxs(:));
    if not(isempty(rowIdxs))
        tableData = arrayfun(@(rowIdx) tableData(rowIdx), rowIdxs);
        tableData = struct2table(tableData);
    else
        tableData = cell2table(cell(0, numCols), 'VariableNames', colLabelsValidified);
    end
end