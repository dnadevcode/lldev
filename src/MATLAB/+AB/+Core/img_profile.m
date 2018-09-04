function [interpVals, xyCoordsInterp] = img_profile(img, xyCoords, numSamples)
    
    validateattributes(img, {'double', 'uint8', 'uint16', 'logical', 'single', 'int16'}, {'nonempty'}, 1);
    validateattributes(xyCoords, {'double'}, {'nonempty', 'ncols', 2}, 2); % each row contains [x, y] for a point
    if nargin >= 3
        validateattributes(numSamples, {'numeric'}, {'positive', 'integer', 'scalar'}, 3);
    end
    
    if ~isa(img, 'double')
        img = single(img);
    end

    
    if nargin < 3
        % find the number of interpolation points required on the profile

        % Find the city-block type distance between consecutive profile points 
        d = diff(xyCoords);
        d = ceil(abs(d));
        % For each segment, consider the maximum of the two directions
        d = max(d, [], 2);
        % Sum it up to get the total number of required points
        numSamples = max(sum(d), 1) + 1;
    end


    % Parametric distance along the segments which make up the profile
    dists = sqrt(sum(diff(xyCoords, 1, 1) .^ 2, 2));
    % Obtain the cumulative distance
    cumDists = [0; cumsum(dists)];

    % Remove duplicate points if necessary.
    dupePtIdxs = find(diff(cumDists) == 0);
    if (~isempty(dupePtIdxs))
        cumDists(dupePtIdxs + 1) = [];
        xyCoords(dupePtIdxs + 1, :) = [];
    end
    


    % Find the coordinates to interpolate at
    xyCoordsInterp = xyCoords;
    if size(xyCoordsInterp, 1) > 1
        % Treat the profile coordinates as a function of the cumulative
        % distance. Interpolate for N new profile coordinates at equally spaced
        % points along the cumulative distance.
        maxCumDist = max(cumDists);
        interpCumDists = 0:(maxCumDist/(numSamples - 1)):maxCumDist;
        try
            xyCoordsInterp = interp1(cumDists, xyCoordsInterp, interpCumDists);
        catch e
            throw e
        end
    end
    
    % Interpolate 
    
    % Image values along interpolation points
    nRows = size(img, 1);
    nCols = size(img, 2);
    interpVals = interp2(1:nCols, 1:nRows, img, xyCoordsInterp(:, 1), xyCoordsInterp(:, 2), '*bilinear');
    
    % If the result is uint8, Promote to double and put NaN's in the places
    % where the profile went out of the image axes (these are zeros because
    % there is no NaN in UINT8 storage class)
    if ~isa(interpVals, 'double')
        outsideAxesMask = ((xyCoordsInterp(:, 1) < 1) | (xyCoordsInterp(:, 1) > nCols) | (xyCoordsInterp(:, 2) < 1) | (xyCoordsInterp(:, 2) > nRows));
        interpVals = double(interpVals);
        interpVals(outsideAxesMask) = NaN;
    end

    interpVals = interpVals(:);
end