function [dbFilepath] = create_sqlite_db(dbName)
    if nargin < 1
        dbName = 'main';
    end
    dbFilepath = [];
    import Fancy.AppMgr.AppResourceMgr;
    defaultDbDirpath = AppResourceMgr.get_dirpath('SQLite');
    defaultDbFilename = sprintf('%s.sqlite3', dbName);
    defaultDbFilepath = fullfile(defaultDbDirpath, defaultDbFilename);
    [dbFilename, dbDirpath, ~] = uiputfile('*.sqlite3', 'Create SQLite File As', defaultDbFilepath);
    if dbDirpath == 0
        warning('Aborting since database location was not specified');
        return;
    end
    if exist(defaultDbFilepath, 'file')
        warning('Database already exists');
        return;
    end
    mode = 'create';
    dbFilepath = fullfile(dbDirpath, dbFilename);
    conn = sqlite(dbFilepath, mode);
    close(conn);
end