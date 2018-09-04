function [tableData] = db_test()

    selectConditions = {};
    tableSchema = 'meltmapschema';
    tableNames = {'videos'; 'kymos'; 'fragments'};
    tableIdx = 1;
    tableName = tableNames{tableIdx};
    kymoIDs = [];
    switch tableName
        case 'videos'
            kymoIDs = [];
        case 'kymos'
            kymoIDs = [];
        case 'fragments'
            kymoIDs = 1;
    end
    
    selectLimit = 1000;
    
    if not(isempty(kymoIDs))
        kymoIDsStr = strjoin(arrayfun(@(kymoID) sprintf('%d', kymoID), kymoIDs(:), 'UniformOutput', false), ', ');
        selectConditions = [selectConditions(:); sprintf('%s IN (%s)', 'kymo_id', kymoIDsStr)];
    end
    
    tableColNames = {'*'};

    
    import MeltmapDB.load_table_data;
    [tableData, tableColMetadata] = load_table_data([], tableSchema, tableName, tableColNames, selectConditions, selectLimit);
    
    if isempty(tableData)
        return;
    end
    
    import MeltmapDB.matlabify_table_data;
    tableData = matlabify_table_data(tableData, tableColMetadata);
end