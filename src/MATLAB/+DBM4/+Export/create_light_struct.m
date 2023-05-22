function [dbmStructLight] = create_light_struct(dbmStruct)
% light structure, only essentials
dbmStructLight.kymoCells = dbmStruct.kymoCells;
dbmStructLight.rawMovieFilenames =  dbmStruct.rawMovieFilenames;
dbmStructLight.rawMovieDirPath =  dbmStruct.rawMovieDirPath;
dbmStructLight.fileCells = [];   
end

