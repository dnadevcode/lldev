function [ moviefile ] = load_movie( filepath,filename )
    % load_movie
    %
    % :param filepath: path to movie.
    % :returns: moviefile

    try
        % add to matlab path
        addpath(genpath(filepath));
        % ful path
        filepath =strcat([filepath filename]);
        % info about movie
        info = imfinfo(filepath);
        % frame numbers
        vec = 1:length(info);
        % movie file
        moviefile = arrayfun(@(x) imread(filepath,x),vec,'UniformOutput',false);
    catch
        moviefile = [];
        return;
    end
       
 

end

