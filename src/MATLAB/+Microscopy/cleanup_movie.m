function [cleanedMovie, cleanupDetails] = cleanup_movie(movieData)
    import OptMap.MovieKymoExtraction.get_outlier_cutoff;

    movieSize = size(movieData);
    outlierCutoff = NaN;
    cleanedMovie = movieData;
    done = false;
    while not(done)
        lastOutlierCutoff = outlierCutoff;
        [outlierCutoff, gumbelCurveMu, gumbelCurveBeta] = get_outlier_cutoff(cleanedMovie);

        movieOutliers = movieData > outlierCutoff;
        movieOutliersIndices = find(movieOutliers(:));
        outlierVals = movieData(movieOutliers);
        numOutliers = length(outlierVals);

        cleanedMovie(movieOutliersIndices) = NaN;
        [xIdxs, yIdxs, frameIdxs] = ind2sub(movieSize, movieOutliersIndices);
        maxFrameNonOutlier = arrayfun(@(frameIdx) nanmax(nanmax(cleanedMovie(:,:,frameIdx))), frameIdxs);
        maxFrameNonOutlier(isnan(maxFrameNonOutlier)) = 0;
        cleanedMovie(movieOutliers) = maxFrameNonOutlier;
        if (outlierCutoff == lastOutlierCutoff)
            done = true;
        end
    end

    minExcluded = min(outlierVals);
    maxIncluded = max(cleanedMovie(:));
    largestExcludedAlpha = 1 - exp(-exp(-(minExcluded - gumbelCurveMu)/gumbelCurveBeta));
    smallestIncludedAlpha = 1 - exp(-exp(-(maxIncluded - gumbelCurveMu)/gumbelCurveBeta));

    cleanupDetails.outlierCutoff = outlierCutoff;
    cleanupDetails.gumbelCurve.mu = gumbelCurveMu;
    cleanupDetails.gumbelCurve.beta = gumbelCurveBeta;
    cleanupDetails.border.minExcluded = minExcluded;
    cleanupDetails.border.maxIncluded = maxIncluded;
    cleanupDetails.border.largestExcludedAlpha = largestExcludedAlpha;
    cleanupDetails.border.smallestIncludedAlpha = smallestIncludedAlpha;
    
    outliersTable = table(...
        xIdxs,...
        yIdxs,...
        frameIdxs,...
        outlierVals,...
        maxFrameNonOutlier,...
        'VariableNames', {'X_Position' 'Y_Position' 'Frame_Number' 'Outlier_Value', 'Replacement_Value'});    
    cleanupDetails.outliers.table = outliersTable;
    cleanupDetails.outliers.count = numOutliers;
    cleanupDetails.outliers.ratioToTotal = numOutliers/numel(movieData);
end