CREATE TABLE meltmapschema.Kymos (
	video_id integer not null,
	kymo_id integer not null unique,
	kymo_name varchar(128),
	background_noise_mean double precision,
	background_noise_variance double precision,
	PRIMARY KEY (kymo_id),
	FOREIGN KEY (video_id) REFERENCES meltmapschema.Videos (video_id)
);