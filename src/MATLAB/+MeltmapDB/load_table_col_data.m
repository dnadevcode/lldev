function [colNames, colsMetaData] = load_table_col_data(conn, tableSchema, tableName, selectionColNames)
    % https://www.postgresql.org/docs/8.0/static/infoschema-columns.html
    infoSchemaSchema = 'information_schema';
    infoSchemaColumnsTable = 'columns';
    if nargin < 4
        import MeltmapDB.load_table_col_data;
        selectionColNames = {'column_name'; 'ordinal_position'};
        [selectionColNames, ~] = load_table_col_data(conn, infoSchemaSchema, infoSchemaColumnsTable, selectionColNames);
    end
    selectionColNames2 = selectionColNames(:);
    if not(any(cellfun(@(colName) strcmp(colName, '*'), selectionColNames2)))
        selectionColNames2 = [selectionColNames2; setdiff({'column_name'; 'ordinal_position'}, selectionColNames)];
        tmpCols = setdiff(selectionColNames2, selectionColNames);
    else
        tmpCols = cell(0, 1);
    end
    selectionColNames2 = strjoin(selectionColNames2, ', ');
    selectConditions2 = {
        sprintf('table_schema = ''%s''', tableSchema), ...
        sprintf('table_name = ''%s''', tableName)
    };
    selectConditions2 = strjoin(selectConditions2, ' AND ');

    selectTablePath2 = sprintf('%s.%s', infoSchemaSchema, infoSchemaColumnsTable);
    sqlQuery = sprintf('SELECT %s FROM %s WHERE %s;', ...
        selectionColNames2, ...
        selectTablePath2, ...
        selectConditions2);
    
    import MeltmapDB.run_sql_query;
    [colsMetaData, ~] = run_sql_query(conn, sqlQuery);
    
    colNames = colsMetaData.column_name;
    colPositions = colsMetaData.ordinal_position;
    [~, so] = sort(colPositions);
    colNames = colNames(so);
    
    numTmpCols = length(tmpCols);
    for tmpColIdx = 1:numTmpCols
        tmpCol = tmpCols{tmpColIdx};
        tmpColField =  matlab.lang.makeValidName(tmpCol);
        colsMetaData.(tmpColField) = [];
    end
end