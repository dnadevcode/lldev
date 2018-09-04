function [outlierCutoff, gumbelCurveMu, gumbelCurveBeta] = get_outlier_cutoff(movieData)
    % Let's assume the values in a frames can roughly be modelled
    % as a normal distribution with some extreme outliers
    % (if it is two normal distributions where one is foreground and
    % another background, that is also okay so long as the foreground
    % distribution is always present and reliably contains higher mean
    % values than extreme high end outliers of the background's
    % normal distribution)
    % Let's assume that the vast majority of frames don't have any
    % extreme outliers and that the extreme outliers that exist
    % are on the high end not the low end
    % Let's then get the maximum values in each frame:
    movieSize = size(movieData);
    if length(movieSize) < 3
        error('Must input movie data where there are multiple frames');
    end
    numFrames = movieSize(3);
    frameMaxes = arrayfun(@(f) max(max(movieData(:,:,f))), 1:numFrames);
    frameMaxes = frameMaxes(:);
    tmpFrameMaxes = frameMaxes;

    tmpMovieData = movieData;
    cleanFrames = false;
    while not(all(cleanFrames))
        % Most values here can be modelled as extreme values from a
        % normal distribution and thus have roughly the distribution of 
        % a gumbel curve if our assumptions are roughly accurate
        gumbelCurveBeta =  std(tmpFrameMaxes) * (sqrt(6)/pi);
        gumbelCurveMu = mean(tmpFrameMaxes) - (gumbelCurveBeta*double(eulergamma()));

        % We want to detect high outliers in these extreme values

        %First let's find out how low the lowest extreme value is
        % and determine the percentile of values in the fitted
        %  distribution that it's supposed to be above
        minimalFrameMax = min(tmpFrameMaxes);

        alpha = exp(-exp(-(minimalFrameMax - gumbelCurveMu)/gumbelCurveBeta));

        % Now let's find the value on the high end of the gumbel
        % distribution which is supposed to be below the same
        % percentile of values and define that as the cutoff for
        % high-end outliers

        outlierCutoff = gumbelCurveBeta * (-log(-log(1 - alpha))) + gumbelCurveMu;

        % Find out which frames, if any have higher values than the
        % outlier cutoff:
        cleanFrames = tmpFrameMaxes <= outlierCutoff;

        if not(all(cleanFrames))
            movieOutliers = tmpMovieData > outlierCutoff;
            movieOutliersIndices = find(movieOutliers(:));
            tmpMovieData(movieOutliersIndices) = NaN;
            [~, ~, frameNums] = ind2sub(movieSize, movieOutliersIndices);
            maxFrameNonOutlier = arrayfun(@(f) nanmax(nanmax(tmpMovieData(:,:,f))), frameNums);
            maxFrameNonOutlier(isnan(maxFrameNonOutlier)) = 0;
            tmpMovieData(movieOutliers) = maxFrameNonOutlier;
            tmpFrameMaxes(frameNums) = maxFrameNonOutlier;
        end
    end
end