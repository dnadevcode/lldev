function [movieRotCycAmpB] = amplify_movie(movieRotCyc, maxAmpDist)
    fprintf('Amplifying movie\n');
    
    fprintf(' starting phase 1\n');
    tic
    movieRotCycAmpA = movieRotCyc;
    import AB.Core.amplify_movie_p1;
    movieRotCycAmpA = amplify_movie_p1(movieRotCycAmpA, maxAmpDist);
    toc
    fprintf(' completed phase 1\n');
    
    fprintf(' starting phase 2\n');
    tic

    movieRotCycAmpB = movieRotCycAmpA;
    import AB.Core.amplify_movie_p2;
    movieRotCycAmpB = amplify_movie_p2(movieRotCycAmpB);
    
    toc
    fprintf(' completed phase 2\n');

    fprintf('Amplified movie\n');
end