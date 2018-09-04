function [fileCells, fileMoleculeCells, pixelsWidths_bps] = import_movies(averagingWindowWidth, tsDBM)
    % IMPORT_MOVIES - Loads multipage tiff files ("movies"), 
    %	detects molecules in the movies, and stores the results
    %    in a few cell arrays
    %
    % Authors:
    %   Charleston Noble
    %   Tobias Ambjörnsson
    %   Saair Quaderi

    import OptMap.DataImport.try_prompt_movie_filepaths;
    [aborted, movieFilepaths] = try_prompt_movie_filepaths();
    [~, movieFilenamesSansExt, movieFileExts] = cellfun(@fileparts, movieFilepaths, 'UniformOutput', false);
    if aborted
        fileCells = cell(0, 1);
        fileMoleculeCells = cell(0, 1);
        pixelsWidths_bps = zeros(0, 1) - 1;
        return;
    end
    movieFilenames = strcat(movieFilenamesSansExt, movieFileExts);
    
    numFiles = numel(movieFilepaths);

    %  Ask user for experimentally determined (using reference molecule)
    %  value for the number of basepairs per pixel for each file


    hBpsPerPixelTab = tsDBM.create_tab('bps/pixel');
    hBpsPerPixelPanel = uipanel(...
        'Parent', hBpsPerPixelTab, ...
        'Position', [0, 0, 1, 1]);
    tsDBM.select_tab(hBpsPerPixelTab);

    import OldDBM.General.Import.prompt_files_bps_per_pixel;
    [pixelsWidths_bps, errorMsg] = prompt_files_bps_per_pixel(movieFilepaths, hBpsPerPixelPanel);
    pixelsWidths_bps = pixelsWidths_bps(:);
    delete(hBpsPerPixelTab);
    waitfor(hBpsPerPixelTab);
    if not(isempty(errorMsg))
        fileCells = cell(0, 1);
        fileMoleculeCells = cell(0, 1);
        pixelsWidths_bps = zeros(0, 1) - 1;
        disp(errorMsg);
        return;
    end

    DEFAULT_SIGNAL_THRESHOLD = 0;
    signalThreshold = DEFAULT_SIGNAL_THRESHOLD;
    % % Ask user for a signal to noise ratio for accepting a detected molecule
    % import OldDBM.General.Import.try_prompt_signal_threshold;
    % [signalThreshold, errorMsg] = try_prompt_signal_threshold(signalThreshold);
    % if not(isempty(errorMsg))
    %     disp(errorMsg);
    %     return;
    % end

    % Go through each of the files.
    fileCells = cell(numFiles, 1);
    fileMoleculeCells = cell(numFiles, 1);
    averagingWindowSideExtensionWidth = floor((averagingWindowWidth - 1)/2);
    
    
    rowSidePadding = 100;
    % fgMaskingSettings.numThresholds = 2;
    % fgMaskingSettings.minThresholdsForegroundMustPass = 1;
    % fgMaskingSettings.minFgCCPixels = 50;
    fgMaskingSettings.maxAmpDist = 2;
    
    for fileNum = 1:numFiles
        filename = movieFilenames{fileNum};
        srcTiffFilepath = movieFilepaths{fileNum};

        fprintf('Importing data from: %s\n', filename);

        % Detect all the molecules in the file, returned as cell of struct.

        gsMovObj = get_grayscale_movie_obj(srcTiffFilepath);
        import Microscopy.GrayscaleMovieStorageMode;
        [~, grayscaleVideo] = gsMovObj.try_get_bounded_data(GrayscaleMovieStorageMode.Normalized);
        
        if (size(grayscaleVideo, 4) > 1) && (size(grayscaleVideo, 3) == 1)
            grayscaleVideo = permute(grayscaleVideo, [1 2 4 3]);
        end
        import OldDBM.MoleculeDetection.detect_molecules;
        [rotatedMovie, miniRotatedMoviesCoords, colCenterIdxs, rowEdgeIdxs] = detect_molecules(grayscaleVideo, averagingWindowSideExtensionWidth, rowSidePadding, signalThreshold, fgMaskingSettings);
        
        miniRotatedMovies = cellfun(@(miniMovieCoords) rotatedMovie(...
                miniMovieCoords(1,1):miniMovieCoords(1,2),...
                miniMovieCoords(2,1):miniMovieCoords(2,2),...
                miniMovieCoords(3,1):miniMovieCoords(3,2)...
            ), ...
            miniRotatedMoviesCoords, ...
            'UniformOutput', false);

        import Fancy.Utils.merge_structs;
        defaultOldMoleculeStruct = struct( ...
                'frames', [], ...
                'kymograph', [], ...
                'information', [], ...
                'passesFilters', true ...
            );
        rawFlatKymos = cellfun(...
            @(miniRotatedMovie) ...
                permute(mean(miniRotatedMovie, 2), [3 1 2]), ...
            miniRotatedMovies, ...
            'UniformOutput', false);


        %	moleculeStructs
        %     a cell with struct entries, one for each molecule detected
        moleculeStructs = cellfun(...
            @(miniRotatedMovie, kymograph) ...
                merge_structs( ...
                    defaultOldMoleculeStruct, ...
                    struct(...
                        'frames', miniRotatedMovie, ...
                        'kymograph',kymograph ...
                        ) ...
                    ), ...
            miniRotatedMovies, ...
            rawFlatKymos, ...
            'UniformOutput', false);

        %	fileStruct
        %    a struct holding data at the file-level
        %      (about the file and where molecules are)
        meanRotatedMovieFrame = mean(rotatedMovie, 3, 'omitnan');
        fileStruct = struct();
        fileStruct.fileName = srcTiffFilepath;
        fileStruct.averagedImg = meanRotatedMovieFrame;
        fileStruct.locs = colCenterIdxs;
        fileStruct.regions = rowEdgeIdxs;
        fileMoleculeCells{fileNum} = moleculeStructs;
        fileCells{fileNum} = fileStruct;
    end


    function [gsMovObj] = get_grayscale_movie_obj(srcTiffFilepath)
        import Fancy.AppMgr.ImportItemContext;
        itemSelectionTime = clock();
        [~, filenamSansExt, fileExt] = fileparts(srcTiffFilepath);
        filename = [filenamSansExt, fileExt];
        displayName = filename;
        importItemContext = ImportItemContext(srcTiffFilepath, itemSelectionTime);


        import Microscopy.Import.import_grayscale_tiff_video;
        fprintf('::> Loading movie for %s...\n', displayName);

        import Microscopy.GrayscaleMovieFactory;
        movieFactory = GrayscaleMovieFactory.get_instance();
        [failMsg, gsMovObj] = movieFactory.load_grayscale_movie_from_tiff(importItemContext.ImportSrcPath);
        if any(failMsg)
            fprintf(' Movie load failure: %s\n', failMsg);
            fprintf('<:: Failed loading movie for %s\n', displayName);
        else
            fprintf('<:: Loaded movie for %s\n', displayName);
        end
    end
    
    fprintf('All file(s) imported and molecules detected\n');
end