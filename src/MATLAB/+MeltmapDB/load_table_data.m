function [tableData, tableColMetadata] = load_table_data(conn, tableSchema, tableName, tableColNames, selectConditions, selectLimit)
    
    if nargin < 4
        tableColNames = {};
    end
    if isempty(tableColNames)
        tableColNames = {'*'};
    end
    if nargin < 5
        selectConditions = {};
    end
    if isempty(selectConditions)
        selectConditions = '';
    else
        selectConditions = strjoin(selectConditions, ' AND ');
        selectConditions = sprintf(' WHERE %s', selectConditions);
    end
    if nargin < 6
        selectLimit = [];
    end
    if isempty(selectLimit)
        selectLimit = Inf;
    end
    if not(isequal(selectLimit, Inf))
        validateattributes(selectLimit, {'numeric'}, {'scalar', 'nonnegative', 'positive', 'integer'}, 6);
    end
    
    if isequal(selectLimit, Inf)
        selectLimit = '';
    else
        selectLimit = sprintf(' LIMIT %d', selectLimit);
    end
    selectColNames = strjoin(tableColNames, ', ');
    selectTablePath = sprintf('%s.%s', tableSchema, tableName);
    sqlQuery = sprintf('SELECT %s FROM %s%s%s;', ...
        selectColNames, ...
        selectTablePath, ...
        selectConditions, ...
        selectLimit);
    
    import MeltmapDB.run_sql_query;
    [tableData, tableColMetadata] = run_sql_query(conn, sqlQuery);
end