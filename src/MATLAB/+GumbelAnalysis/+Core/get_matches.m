function [matchMatricesByIteration, outlierScoresMatricesByIteration, gumbelCurveMusByIteration, gumbelCurveBetasByIteration, includedValueMeansByDim, includedValueStdsByDim] = get_matches(alpha, valuesMatrix, dim)
    validateattributes(alpha, {'numeric'}, {'nonnegative', 'finite', 'real', 'scalar'}, 1);
    validateattributes(valuesMatrix, {'numeric'}, {'real'}, 2);
    if nargin < 3
        dim = 1;
    else
        validateattributes(dim, {'numeric'}, {'positive', 'integer', 'finite', 'real', 'scalar'}, 3);
    end

    matrixSize = size(valuesMatrix);
    repmatTiling = ones(1, length(size(matrixSize)));
    if length(matrixSize) <= dim
        repmatTiling(dim) = matrixSize(dim);
    end

    valuesNotDone = matrixSize;
    valuesNotDone(dim) = 1;
    valuesNotDone = true(valuesNotDone);
    outlierExclusionMatrix = false(matrixSize);
    includedValuesMatrix = valuesMatrix;
    % includedValuesMatrix(outlierExclusionMatrix) = NaN;
    outlierScoresMatricesByIteration = {};
    matchMatricesByIteration = {};
    gumbelCurveBetasByIteration = {};
    gumbelCurveMusByIteration= {};

    while any(valuesNotDone(:))
        % performance note: with some work this could be optimized
        %   so that calculations are not repeated for vectors
        %   where the excluded values have not changed
        includedValueMeansByDim = nanmean(includedValuesMatrix, dim); % dim-wise means excluding NaNs
        includedValueStdsByDim = nanstd(includedValuesMatrix, 0, dim);% dim-wise stds excluding NaNs

        gumbelCurveBetas =  includedValueStdsByDim * (sqrt(6)/pi);
        gumbelCurveMus = includedValueMeansByDim - (gumbelCurveBetas*double(eulergamma()));
        gumbelCurveBetasByIteration{end + 1} = gumbelCurveBetas;
        gumbelCurveMusByIteration{end + 1} = gumbelCurveMus;

        gumbelCurveMus2 = repmat(gumbelCurveMus, repmatTiling);
        gumbelCurveBetas2 = repmat(gumbelCurveBetas, repmatTiling);

        outlierScoresMatrix = 1 - exp(-exp(-(valuesMatrix - gumbelCurveMus2)./gumbelCurveBetas2));
        matchMatrix = (outlierScoresMatrix < alpha); % & not(isnan(outlierScoresMatrix)) is implied
        outlierScoresMatricesByIteration{end + 1} = outlierScoresMatrix;
        matchMatricesByIteration{end + 1} = matchMatrix;
        newMatchMatrix = matchMatrix & not(outlierExclusionMatrix);
        valuesNotDone = any(newMatchMatrix, dim);
        if any(valuesNotDone(:))
            includedValuesMatrix(newMatchMatrix) = NaN;
            outlierExclusionMatrix = outlierExclusionMatrix | matchMatrix;
        end
    end
end