function [movieAmplified] = amplify_molecules(movieNrm, amplificationKernel)
    if any(mod(size(amplificationKernel), 2) == 0)
        error('Convolution array for amplification kernel must have an odd-length in each dimension');
    end
    for dimNum=1:3
        if not(isequal(amplificationKernel, flip(amplificationKernel, dimNum)))
            error('Convolution array for amplification kernel must be symmetrical in each dimension');
        end
    end

    padSize = ((size(amplificationKernel) - 1)/2);
    
    import Microscopy.get_padding_recropping_idxs_symm_both;
    [idxsForPadding, idxsForRecropping] = get_padding_recropping_idxs_symm_both(size(movieNrm), padSize, 1);
    paddedMovie = movieNrm(idxsForPadding{:});
    
    paddedMovieAmplified = convn(paddedMovie, amplificationKernel, 'same'); % convolve against kernel
    
    movieAmplified = paddedMovieAmplified(idxsForRecropping{:}); % remove all padding from result
    
    % normalize to min of 0 and max of 1
    movieAmplified = movieAmplified - min(movieAmplified(:));
    movieAmplified = movieAmplified./max(movieAmplified(:));
    
    % warp values to increase contrast
    movieAmplified = movieAmplified.^2;
end