function [ A ] = import_movies( folder )
    % import movies from folder to matrix structure
    addpath(genpath(folder));
    fd = dir(folder);

    A = cell(1,length(fd)-2);
    for i=3:length(fd)
        for j=1:length(imfinfo(fd(i).name))
            A{i-2}.img(:,:,j) = imread(fd(i).name,j);
        end
    end



end

