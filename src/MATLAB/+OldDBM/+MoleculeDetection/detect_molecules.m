function [grayscaleVideoRescaled, miniRotatedMoviesCoords, colCenterIdxs, rowEdgeIdxs] = detect_molecules(grayscaleVideo, settings)
    % detect_molecules - takes a tif video file (with path fname), an averaging window
    %	width (typically 3 pixels), and a noise threshold (signalAboveNoise),
    %	and finds molecules in the movies. It returns a struct for each molecule.
    %
    % Args:
    %   grayscaleVideo: grayscale video where third dimension represents timeframe
    %   settings: settings structure containing all the settings
    %
    % Returns:
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
    %   Albertas Dvirnas
    
    
    averagingWindowSideExtensionWidth = floor((settings.averagingWindowWidth - 1)/2);
    signalThreshold = settings.signalThreshold;
    rowSidePadding = settings.rowSidePadding;
    fgMaskingSettings = settings.fgMaskingSettings;
    fgMaskingSettings.rowSidePadding = rowSidePadding;
    % 
%     fgMaskingSettings.filterEdgeMolecules = averagingWindowSideExtensionWidth;
    % fgMaskingSettings.numThresholds = 2;
    % fgMaskingSettings.minThresholdsForegroundMustPass = 1;
    % fgMaskingSettings.minFgCCPixels = 50;


    % minimum and maximum values of the molecule
    minVal = min(grayscaleVideo(:));
    maxVal = max(grayscaleVideo(:));
    % scale the movie to [0,1]
    
    grayscaleVideoRescaled = (grayscaleVideo - minVal)./(maxVal - minVal);
    
    clear grayscaleVideo;
    
    % get an amplification kernel
    import OldDBM.MoleculeDetection.get_amplification_filter_kernel;
    amplificationFilterKernel = get_amplification_filter_kernel();
    % amplify
    amplifiedGrayscaleMovie = convn(grayscaleVideoRescaled, amplificationFilterKernel, 'same').*grayscaleVideoRescaled;

    if settings.rotateMovie
        % compute an angle using HOUGH transformation
        import OldDBM.MoleculeDetection.get_angle;
        rotationAngle = get_angle(amplifiedGrayscaleMovie);


        ninetyDegRotations = round(rotationAngle/90);
        finetunedRotation = rotationAngle - ninetyDegRotations*90;
        % ninetyDegRotations = ninetyDegRotations + 1; % Orient Channels Vertically
        ninetyDegRotations = mod(ninetyDegRotations, 4);

%         rotatedMovie = grayscaleVideoRescaled;
        grayscaleVideoRescaled = rot90(grayscaleVideoRescaled, ninetyDegRotations);
        if finetunedRotation ~= 0
            warning('Movie data is being rotated via bilinear interpolation');
            grayscaleVideoRescaled = imrotate(grayscaleVideoRescaled, finetunedRotation, 'bilinear','crop');
        end
    end
    % rotatedAmplifiedMovie = amplifiedGrayscaleMovie;
    % rotatedAmplifiedMovie = rot90(rotatedAmplifiedMovie, ninetyDegRotations);
    % if finetunedRotation ~= 0
    %     rotatedAmplifiedMovie = imrotate(rotatedAmplifiedMovie, finetunedRotation, 'bilinear', 'crop');
    % end
    % import OldDBM.MoleculeDetection.get_foreground_mask;
    % imgFgMask = get_foreground_mask(rotatedAmplifiedMovie, fgMaskingSettings);
    
%     figure,imagesc(rotatedMovie(:,:,1))
    


    fprintf('Detecting molecules...\n');

    import OldDBM.MoleculeDetection.find_molecule_positions;
    [rowEdgeIdxs, colCenterIdxs] = find_molecule_positions(grayscaleVideoRescaled, fgMaskingSettings, signalThreshold);


    numMoleculesDetected = size(rowEdgeIdxs, 1);

    fprintf('Detected a total of %d molecules.\n\n', numMoleculesDetected);
    if numMoleculesDetected==0
        miniRotatedMoviesCoords = {};
    else
        colSidePadding = averagingWindowSideExtensionWidth;
        rotatedMovieSz = size(grayscaleVideoRescaled);

        import OldDBM.MoleculeDetection.get_molecule_movie_coords;
        [miniRotatedMoviesCoords] = get_molecule_movie_coords(rowEdgeIdxs, colCenterIdxs, rotatedMovieSz, rowSidePadding, colSidePadding);
    end
end