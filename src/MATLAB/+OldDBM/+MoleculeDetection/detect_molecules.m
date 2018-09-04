function [rotatedMovie, miniRotatedMoviesCoords, colCenterIdxs, rowEdgeIdxs] = detect_molecules(grayscaleVideo, averagingWindowSideExtensionWidth, rowSidePadding, signalThreshold, fgMaskingSettings)
    % DETECT_MOLECULES - takes a tif video file (with path fname), an averaging window
    %	width (typically 3 pixels), and a noise threshold (signalAboveNoise),
    %	and finds molecules in the movies. It returns a struct for each molecule.
    %
    % Inputs:
    %   grayscaleVideo
    %     grayscale video where third dimension represents timeframe
    %   averagingWindowSideExtensionWidth
    %     the width of the molecule (the molecule width dimension for the
    %     mini movies will be determined based on this)
    %   rowSidePadding
    %     the amount of background to include on the side of the molecules
    %     in the coordinates
    %   signalThreshold
    %     the threshold used for molecule detection
    %   fgMaskingSettings
    %     foreground masking settings struct
    %
    % Outputs:
    %   rotatedMovie
    %    the rotated movie
    %   miniRotatedMoviesCoords
    %    coordinate ranges in the movie for the molecules that were
    %    detected
    %   colCenterIdxs
    %     the index of the central column for each molecule in the rotated
    %     movie
    %   rowEdgeIdxs
    %     the indices of the edge rows for each molecule in the rotated
    %     movie
    %
    % Authors:
    %   Charleston Noble
    
    minVal = min(grayscaleVideo(:));
    maxVal = max(grayscaleVideo(:));
    grayscaleVideoRescaled = (grayscaleVideo - minVal)./(maxVal - minVal);
    import OldDBM.MoleculeDetection.get_amplification_filter_kernel;
    amplificationFilterKernel = get_amplification_filter_kernel();

    amplifiedGrayscaleMovie = convn(grayscaleVideoRescaled, amplificationFilterKernel, 'same').*grayscaleVideoRescaled;

    import OldDBM.MoleculeDetection.get_angle;
    rotationAngle = get_angle(amplifiedGrayscaleMovie);


    ninetyDegRotations = round(rotationAngle/90);
    finetunedRotation = rotationAngle - ninetyDegRotations*90;
    % ninetyDegRotations = ninetyDegRotations + 1; % Orient Channels Vertically
    ninetyDegRotations = mod(ninetyDegRotations, 4);

    rotatedMovie = grayscaleVideoRescaled;
    rotatedMovie = rot90(rotatedMovie, ninetyDegRotations);
    if finetunedRotation ~= 0
        warning('Movie data is being rotated via bilinear interpolation');
        rotatedMovie = imrotate(rotatedMovie, finetunedRotation, 'bilinear','crop');
    end

    % rotatedAmplifiedMovie = amplifiedGrayscaleMovie;
    % rotatedAmplifiedMovie = rot90(rotatedAmplifiedMovie, ninetyDegRotations);
    % if finetunedRotation ~= 0
    %     rotatedAmplifiedMovie = imrotate(rotatedAmplifiedMovie, finetunedRotation, 'bilinear', 'crop');
    % end
    % import OldDBM.MoleculeDetection.get_foreground_mask;
    % imgFgMask = get_foreground_mask(rotatedAmplifiedMovie, fgMaskingSettings);
    
    


    fprintf('Detecting molecules...\n');

    import OldDBM.MoleculeDetection.find_molecule_positions;
    [rowEdgeIdxs, colCenterIdxs] = find_molecule_positions(rotatedMovie, fgMaskingSettings, signalThreshold);


    numMoleculesDetected = size(rowEdgeIdxs, 1);

    fprintf('Detected a total of %d molecules.\n\n', numMoleculesDetected);
    if numMoleculesDetected==0
        miniRotatedMoviesCoords = {};
    else
        colSidePadding = averagingWindowSideExtensionWidth;
        rotatedMovieSz = size(rotatedMovie);

        import OldDBM.MoleculeDetection.get_molecule_movie_coords;
        [miniRotatedMoviesCoords] = get_molecule_movie_coords(rowEdgeIdxs, colCenterIdxs, rotatedMovieSz, rowSidePadding, colSidePadding);
    end
end