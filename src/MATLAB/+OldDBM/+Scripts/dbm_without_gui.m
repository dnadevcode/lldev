function [ dbmODW ] = dbm_without_gui(filepath, sets )
    % dbm without gui, extracting kymographs from a movie
    if nargin < 2
%         sets = some default sets
    end
    
    % a script to run dbm without gui
    
    import OldDBM.General.Import.import_movies;
    [fileCells, fileMoleculeCells, pixelsWidths_bps] = import_movies(averagingWindowWidth, tsDBM);

    dbmODW.DBMMainstruct.fileCell = fileCells;
    dbmODW.DBMMainstruct.fileMoleculeCell = fileMoleculeCells;


end

