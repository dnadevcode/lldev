-- View: meltmapschema.kymos_timeframes

-- DROP VIEW meltmapschema.kymos_timeframes;

CREATE OR REPLACE VIEW meltmapschema.kymos_timeframes AS
 SELECT f2.kymo_id,
    f2.timeframe_index,
    count(f2.fragment_id) AS agg_fragments_count,
    sum(f2.length) AS agg_length,
    sum(f2.intensity_sum) AS agg_intensity_sum,
    sum(f2.intensity_sum) / sum(f2.length)::double precision AS agg_intensity_mean,
    max(f2.intensity_maximum) AS agg_intensity_maximum,
    min(f2.intensity_minimum) AS agg_intensity_minimum
   FROM ( SELECT fragments.kymo_id,
            fragments.fragment_id,
            fragments.timeframe_index,
            1 + fragments.index_right - fragments.index_left AS length,
            fragments.intensity_sum,
            fragments.intensity_maximum,
            fragments.intensity_minimum
           FROM meltmapschema.fragments) f2
  GROUP BY f2.kymo_id, f2.timeframe_index;
