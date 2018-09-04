function tableData = matlabify_table_data(tableData, tableColMetadata)
    tableColNames = tableColMetadata.column_name;
    dateFields = tableColNames(cellfun(@(x) strcmpi(x, 'java.sql.Date'), tableColMetadata.column_class_name));
    timeFields = tableColNames(cellfun(@(x) strcmpi(x, 'java.sql.Time'), tableColMetadata.column_class_name));
    numDateFields = length(dateFields);
    for dateFieldIdx = 1:numDateFields
        dateField = matlab.lang.makeValidName(dateFields{dateFieldIdx});
        tmp = tableData.(dateField);
        tmp = arrayfun(@convert_to_string, tmp, 'UniformOutput', false);
        tableData.(dateField) = tmp;
    end

    numTimeFields = length(timeFields);
    for timeFieldIdx = 1:numTimeFields
        timeField = matlab.lang.makeValidName(timeFields{timeFieldIdx});
        tmp = tableData.(timeField);
        tmp = arrayfun(@convert_to_string, tmp, 'UniformOutput', false);
        tableData.(timeField) = tmp;
    end


    function val = convert_to_string(val)
        if iscell(val) && (length(val) == 1)
            val = val{1};
        end
        if isempty(val)
            val = [];
        else
            val = char(val.toString());
        end
    end
end