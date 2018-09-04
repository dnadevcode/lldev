function pValApproxMovieFg = make_pval_approx_movie(movieWithVertChannels)
    % MAKE_PVAL_APPROX_MOVIE
    %
    % Inputs:
    %   movieWithVertChannels
    %      movie with raw intensity values with vertical channels
    %      containing molecules with flourophores
    %
    % Outputs:
    %   pValApproxMovieB
    %      a p-value approximation for foreground amplification
    %
    % Authors:
    %  Saair Quaderi

    % Note: As of 2017-05 this code is not actually used anywhere
    
    % Define background pixels as pixels where the intensity has no significant
    %  contribution from fluorescence coming from fluorophores on molecules 
    % Assume background pixel intensities fall on a normal distribution
    % Assume that the median value in each frame is approximately equal to the
    %   mean value for the distribution of background pixel intensities
    %  (This should be ok so long as the field of view consists predominantly
    %    of background pixels)
    % Assume that the mean value for the median intensity value in each frame
    %   is approximately equal to the mean value of background pixel
    %   intensities for the whole movie
    %   (So long as the background intensity distribution for the frames are
    %   the same, this should be ok)
    % Assume that values in the movie lower than this mean approximation are
    %   almost exclusively background pixel intensities
    % Calculate the approximate standard deviation from these lower values
    % Calculate the approximate p-value for the intensities of all pixels
    %   with respect to the background intensity normal distribution
    %   given by the approximations for the mean and deviation


    pValApproxMovieA = movieWithVertChannels;
    import Fancy.Utils.multidim_reduce;
    [frameMedians] = multidim_reduce(movieWithVertChannels, [1 2 3], @median);
    frameMedians = frameMedians(:);
    bgMeanValApprox = mean(frameMedians);
    lowerBgValsApprox = pValApproxMovieA(pValApproxMovieA <= bgMeanValApprox);
    stdApprox = sqrt(mean((bgMeanValApprox - lowerBgValsApprox).^2));
    pValApproxMovieA = (pValApproxMovieA - bgMeanValApprox)./stdApprox; % approximate zscore
    pValApproxMovieA = 1 - normcdf(pValApproxMovieA);


    % Assume that for background pixels, the p-value for a pixel is independent
    %  of neighboring pixels, but that for the other pixels (foreground pixels)
    %  the values are expected to be low and concentrated next to one another
    % Exploit this to try to detect foreground pixels

    % expected background value distribution for pValApprox:
    %   uniform continuous distribution between 0-1
    %     => expected mean is 1/2
    %     => expected variance is 1/12
    % Bienaymé formula says variance of the mean of k independent
    %   random variables from a distribution should be expected to be
    %   the variance of the distribution divided by k

    rowDist = 2;
    colDist = 1;
    numKernelRows = 1 + (2*rowDist);
    numKernelCols = 1 + (2*colDist);
    nhoodSampleSize = numKernelRows * numKernelCols;
    averagingKernel = ones(numKernelRows, numKernelCols) ./ nhoodSampleSize;
    bgExpectedSampleMean = 0.5;
    bgExpectedSampleVar = 1/(12 * nhoodSampleSize);
    bgExpectedSampleStd = sqrt(bgExpectedSampleVar);
    pValApproxMovieFg = convn(pValApproxMovieA, averagingKernel, 'valid');
    pValApproxMovieFg = (pValApproxMovieFg - bgExpectedSampleMean)./bgExpectedSampleStd; % approximate zscore
    pValApproxMovieFg = normcdf(pValApproxMovieFg);

end