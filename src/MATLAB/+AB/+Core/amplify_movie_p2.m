function [movieRotCycAmpB] = amplify_movie_p2(movieRotCycAmpA)
    ampMolDetectKernel = [-1.5 -0.25 1.25 2 1.25 -0.25 -1.5];
    movieRotCycAmpB = movieRotCycAmpA;
    movieRotCycAmpB = convn(movieRotCycAmpB, ampMolDetectKernel, 'valid');
    movieRotCycAmpB = movieRotCycAmpB - min(movieRotCycAmpB(:));
    movieRotCycAmpB = movieRotCycAmpB ./ max(movieRotCycAmpB(:));
end