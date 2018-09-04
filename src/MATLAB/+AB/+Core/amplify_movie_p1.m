function movieAmp = amplify_movie_p1(movie, maxAmpDist)
    import Microscopy.generate_planar_amp_kernel;
    ampKernel = generate_planar_amp_kernel(maxAmpDist);
    movieAmp = movie;
    movieAmp = convn(movieAmp, ampKernel, 'valid');
    movieAmp = movieAmp - min(movieAmp(:));
    movieAmp = movieAmp ./ max(movieAmp(:));
    % movieAmp = sign(movieAmp) .* (movieAmp .^ 2);
    movieAmp = movieAmp .^ 2;
end
