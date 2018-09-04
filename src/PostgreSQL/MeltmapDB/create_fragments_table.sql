CREATE TABLE meltmapschema.Fragments (
	kymo_id integer not null,
	timeframe_index smallint,
	fragment_id integer not null,
	index_left smallint,
	index_right smallint,
	intensity_sum double precision,
	intensity_variance double precision,
	intensity_maximum double precision,
	intensity_minimum double precision,
	intensity_median double precision,
	PRIMARY KEY (kymo_id, fragment_id),
	FOREIGN KEY (kymo_id) REFERENCES meltmapschema.Kymos (kymo_id)
);