function conn = connect_to_db(meltmapConnSettings)
    if nargin < 1
        meltmapConnSettings = [];
    end
    if isempty(meltmapConnSettings)
        import MeltmapDB.load_meltmap_conn_settings;
        meltmapConnSettings = load_meltmap_conn_settings();
    end
    if isempty(meltmapConnSettings)
        conn = [];
        return;
    end
    
    if not(exist('org.postgresql.Driver', 'class'))
        import MeltmapDB.download_postgresql_driver;
        download_postgresql_driver();
    end
    if not(exist('org.postgresql.Driver', 'class'))
        error('Missing Java jar for postgresql JDBC driver');
    end

    % Create the database connection (port 5432 is the default postgres chooses
    % on installation)
    driver = org.postgresql.Driver;
    url = sprintf('jdbc:postgresql://%s:%d/%s', meltmapConnSettings.hostname, meltmapConnSettings.port, meltmapConnSettings.db);

    % Username and password you chose when installing postgres
    props = java.util.Properties;
    props.setProperty('user', meltmapConnSettings.user);
    props.setProperty('password', meltmapConnSettings.password);
    
    conn = driver.connect(url, props);
end