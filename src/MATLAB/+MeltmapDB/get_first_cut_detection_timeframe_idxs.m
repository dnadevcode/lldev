function [timeframeIdxsFirstCut, kymoIDs, precutDataTables] = get_first_cut_detection_timeframe_idxs(kymoIDs)
    if nargin < 1
        kymoIDs = [];
    end
    sqlQueryA = sprintf('SELECT kymo_id, MIN(timeframe_index) as first_cut_idx FROM meltmapschema.kymos_timeframes WHERE (agg_fragments_count = %d) GROUP BY kymo_id', 2);
    import MeltmapDB.load_meltmap_conn_settings;
    meltmapConnSettings = load_meltmap_conn_settings();
    import MeltmapDB.connect_to_db;
    conn = connect_to_db(meltmapConnSettings);
    import MeltmapDB.run_sql_query;
    [tableDataA, ~] = run_sql_query(conn, sqlQueryA);
    if isempty(kymoIDs)
        kymoIDs = unique(tableDataA.kymo_id);
    end
    numKymos = numel(kymoIDs);
    timeframeIdxsFirstCut = NaN(size(kymoIDs));
    precutDataTables = cell(numKymos, 1);
    for kymoIdx = 1:numKymos
        % fprintf('%d/%d\n', kymoIdx, numKymos);
        kymoID = kymoIDs(kymoIdx);
        firstCutIdx = tableDataA.first_cut_idx(tableDataA.kymo_id == kymoID);
        if not(isempty(firstCutIdx(not(isnan(firstCutIdx)))))
            sqlQueryTmp = sprintf('SELECT agg_length, agg_intensity_sum, agg_intensity_mean FROM meltmapschema.kymos_timeframes WHERE (timeframe_index < %d) AND (kymo_id = %d)', firstCutIdx, kymoID);
            [precutDataTables{kymoIdx}, ~] = run_sql_query(conn, sqlQueryTmp);
        end
        if isempty(firstCutIdx)
            firstCutIdx = NaN;
        end
        timeframeIdxsFirstCut(kymoIdx) = firstCutIdx;
    end
    
end