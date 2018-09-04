function [tableData, tableColMetadata] = run_sql_query(conn, sqlQuery)
    closeConnectionAfterLoadTF = isempty(conn);
    if closeConnectionAfterLoadTF
        import MeltmapDB.connect_to_db;
        conn = connect_to_db();
        if isempty(conn)
            closeConnectionAfterLoadTF = false;
            tableData = [];
            tableColMetadata = [];
            return;
        end
        
    end
    
    psQuery = conn.prepareStatement(sqlQuery);
    rsQuery = psQuery.executeQuery();
    import MeltmapDB.sql_result_set_to_matlab_data_table;
    [tableData, tableColMetadata] = sql_result_set_to_matlab_data_table(rsQuery);

    if closeConnectionAfterLoadTF
        conn.close();
    end
end