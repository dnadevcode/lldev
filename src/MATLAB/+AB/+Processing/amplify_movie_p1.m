function movieAmp = amplify_movie_p1(movie, maxAmpDist)
    % amplify_movie_p1
    
    % :param movie: input array
    % :param maxAmpDist: aplification parameter
    %
    % :returns: movieAmp
    
    % rewritten by Albertas Dvirnas
    
    % phase one of amplification. Simple square filter
    
    import Microscopy.generate_planar_amp_kernel;

    % First we generate the amplification kernel
    ampKernel = generate_planar_amp_kernel(maxAmpDist);
    
    % make a copy of the movie
    movieAmp = movie;
    
    % computes n dimensional convolution
    movieAmp = convn(movieAmp, ampKernel, 'valid');
    
    % rescale 
    movieAmp = movieAmp - min(movieAmp(:));
    movieAmp = movieAmp ./ max(movieAmp(:));
    % movieAmp = sign(movieAmp) .* (movieAmp .^ 2);
    
    % take the square
    movieAmp = movieAmp .^ 2;
end
