function [  ] = export_movie( movie,fold )
    
    foldful = strcat( [ fold num2str(randi(100,1)) '.tif']);
    imwrite(movie(:,:,1),foldful)
    for i =2:size(movie,3)
        imwrite(movie(:,:,i),foldful,'WriteMode','append');
    end

end

