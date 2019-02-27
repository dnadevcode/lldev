function [movieRotCycAmpB] = amplify_movie_p2(movieRotCycAmpA)
    % amplify_movie_p2
    
    % :param movieRotCycAmpA: movie array
    %
    % :returns: movieRotCycAmpB filtered movie array
    
    % convolution in y, along the molecules. 
    

    % todo: make the size of this importable through settings and tunable
    ampMolDetectKernel = [-1.5 -0.25 1.25 2 1.25 -0.25 -1.5];
    movieRotCycAmpB = movieRotCycAmpA;
    movieRotCycAmpB = convn(movieRotCycAmpB, ampMolDetectKernel, 'valid');
    
    % rescale
    movieRotCycAmpB = movieRotCycAmpB - min(movieRotCycAmpB(:));
    movieRotCycAmpB = movieRotCycAmpB ./ max(movieRotCycAmpB(:));
end