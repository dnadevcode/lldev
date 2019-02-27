function [movieRotCyc] = amplify_movie(movieRotCyc, maxAmpDist)
    % amplify_movie
    
    % :param movieRotCyc: input array
    % :param maxAmpDist: aplification parameter
    %
    % :returns: movieRotCycAmpB
    
    % rewritten by Albertas Dvirnas
    
    import AB.Processing.amplify_movie_p1;
    import AB.Processing.amplify_movie_p2;

    % Amplify movie phase 1   
    movieRotCyc = amplify_movie_p1(movieRotCyc, maxAmpDist);

    % Amplify movie phase 2
    movieRotCyc = amplify_movie_p2(movieRotCyc);
 
end