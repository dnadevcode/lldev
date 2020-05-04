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
   
    szMovieIn = size(grayscaleVideo);

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
    
% 
%         ninetyDegRotations = round(rotationAngle/90);
%         finetunedRotation = rotationAngle - ninetyDegRotations*90;
%         % ninetyDegRotations = ninetyDegRotations + 1; % Orient Channels Vertically
%         ninetyDegRotations = mod(ninetyDegRotations, 4);
% 
% %         rotatedMovie = grayscaleVideoRescaled;
%         grayscaleVideoRescaled = rot90(grayscaleVideoRescaled, ninetyDegRotations);
%         if finetunedRotation ~= 0
%            % warning('Movie data is being rotated via bilinear interpolation');
%             bboxMode = 'crop';
%             % should we have crop/loose here?
%             grayscaleVideoRescaled = imrotate(grayscaleVideoRescaled, finetunedRotation, 'bilinear',bboxMode);
%             
% %             add zeros to the edges since bilinear interpolation does not
% %             deal well with these
%             c = zeros(szMovieIn(1),szMovieIn(2));
%             c(2:end-1,2:end-1) = 1;
%             
%             % create a Cartesian grid 
% %             [c, r] = meshgrid((1:szMovieIn(2)), (1:szMovieIn(1)));
% % 
%     %     % method for coordinate matrix should be 'nearest' to avoid artifacts
%     %     % when doing bilinear interpolation (then between 200 and 0 there's
%     %     % 100, while in fact it should be 0. Note that this only allows us to
%     %     % see where there are nonzero pixels, though we can't use them to index
%     %     % the coordinates. todo: do both
%             rotationSamplingMethod = 'nearest';
% 
%             % rotate the X coordinate matrix
%             segmentFrameRot = imrotate(c, finetunedRotation, rotationSamplingMethod, bboxMode);
% 
%             % rotate the Y coordinate matrix
% %             cRot = imrotate(c, rotationAngle, rotationSamplingMethod, bboxMode);
% 
%             % we care only abound indices that were in original grid. These are the
%             % points that have length(y)>=r>=1, length(x)>c>=1. 
%             % can we find cases where extra points are denoted as non zero?
% %             segmentFrameRot = (rRot >= 1) & (rRot <= szMovieIn(1)) & (cRot >= 1) & (cRot <= szMovieIn(2));
%             for i=1:size(grayscaleVideoRescaled,3)
%                 tempImg = grayscaleVideoRescaled(:,:,i);
%                 tempImg(~segmentFrameRot) = 0;
%                 grayscaleVideoRescaled(:,:,i) = tempImg;
%             end
%             
%             
%         
%         end
       
    end
        

%     end
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
        [rotatedMovieSz(1), rotatedMovieSz(2), rotatedMovieSz(3)] = size(grayscaleVideoRescaled);

        import OldDBM.MoleculeDetection.get_molecule_movie_coords;
        [miniRotatedMoviesCoords] = get_molecule_movie_coords(rowEdgeIdxs, colCenterIdxs, rotatedMovieSz, rowSidePadding, colSidePadding);
    end
end