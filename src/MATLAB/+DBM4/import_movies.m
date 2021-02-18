function [fileCells, fileMoleculeCells, pixelsWidths_bps] = import_movies(sets)
    % IMPORT_MOVIES - Loads multipage tiff files ("movies"), 
    %	detects molecules in the movies, and stores the results
    %    in a few cell arrays
    %
    %   Args:
    %
    %   Returns:
    %


%     sets.movies.askForMovies = 1;
    
    
    if ~sets.movies.askForMovies
        try 
            fid = fopen(sets.movies.movieFile); 
            fastaNames = textscan(fid,'%s','delimiter','\n'); fclose(fid);
            for i=1:length(fastaNames{1})
                [FILEPATH,NAME,EXT] = fileparts(fastaNames{1}{i});

                sets.movies.filenames{i} = strcat(NAME,EXT);
                sets.movies.kymofilefold{i} = FILEPATH;
            end
        catch
            sets.movies.askForMovies   = 1;
        end
%         sets.kymosets.kymoFile = 'kymos_2020-03-13_14_06_31_.txt';
    end
    
    
    if sets.movies.askForMovies
    % loads figure window
        import Fancy.UI.Templates.create_figure_window;
        [hMenuParent, tsDBM] = create_figure_window('DBM movie import tool','DBM');

        import Fancy.UI.Templates.create_import_tab;
        cache = create_import_tab(hMenuParent,tsDBM,'movie');
        uiwait(gcf);  

        dd = cache('selectedItems');
        sets.movies.filenames = dd(1:end/2);
        sets.movies.kymofilefold = dd((end/2+1):end);
        delete(hMenuParent);
    end


    movieFilenames = fullfile(sets.movies.kymofilefold , sets.movies.filenames);
    numFiles = numel(movieFilenames);

    % pixelwidthbp is not used here.. / assume all have the same/ otherwise
    % read this off filename
    pixelsWidths_bps = zeros(numFiles,1) - 1;

   % Go through each of the files.
    fileCells = cell(numFiles, 1);
    fileMoleculeCells = cell(numFiles, 1);

 
%             DEFAULT_SIGNAL_THRESHOLD = 0;
%             signalThreshold = DEFAULT_SIGNAL_THRESHOLD;
            % % Ask user for a signal to noise ratio for accepting a detected molecule
%             import OldDBM.General.Import.try_prompt_signal_threshold;
%             [signalThreshold, errorMsg] = try_prompt_signal_threshold(signalThreshold);
            % if not(isempty(errorMsg))
            %     disp(errorMsg);
            %     return;
            % end
 
    for fileNum = 1:numFiles
        filename = movieFilenames{fileNum};
        srcTiffFilepath = fullfile(sets.movies.kymofilefold{fileNum},sets.movies.filenames{fileNum});

        fprintf('Importing data from: %s\n', filename);

%        fileloc = fullfile(sets.moviesets.moviefilefold{idx},sets.moviesets.filenames{idx});
        % load one of the movies and frame numbers
        info = imfinfo(filename); 
        if sets.movies.max_number_of_frames == 0
            vec = 1:min(length(info));
        else
            vec = 1:min(length(info),sets.movies.max_number_of_frames);
        end
        
%         [filepath,name,ext] = fileparts(fileloc);
        % movie file
        movie = arrayfun(@(x) imread(filename,x),vec,'UniformOutput',false);
       
       grayscaleVideo = double(cat(3, movie{:}));
        if sets.movies.denoise
           imAverage = imgaussfilt(mean(grayscaleVideo,3),[10,10]);
           grayscaleVideo = grayscaleVideo-imAverage;
           grayscaleVideo(grayscaleVideo<0) = 0;
        end
%         [imDenoised] = denoise_image( imAverage );

        % detect molecules
        import DBM4.detect_molecules;
        [rotatedMovie, moleculeStructs, colCenterIdxs, rowEdgeIdxs] = detect_molecules(grayscaleVideo, sets);
         
        
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

%         avgMovie = mean(movie3d,3);
%         
%         
%         % take a number of points from the movie (make sure that this
%         % includes both signal and background. Assume that distribution is
%         % Gaussian
%         numRandPts =1000;
%         thousandPointsX = randsample(size(movie3d,1),numRandPts,1);
%         thousandPointsY = randsample(size(movie3d,2),numRandPts,1);
%         thousandPointsZ = randsample(size(movie3d,3),numRandPts,1);
%         pt = zeros(1,numRandPts)
%         for i=1:numRandPts
%             pt(i) = movie3d(thousandPointsX(i),thousandPointsY(i),thousandPointsZ(i));
%         end
%         
%         [m,s] = normfit(pt);
%         m+3*s

%     randPoints = movie3d(

        
        
%         movie = []

        % clean up high intensity values..
        
                
        %             fitRangeToCleanedDataMode = 0; % TODO: make this work for single frame with 1
        
        % clean up ununiform data, where some molecule have very high
        % intensity peaks
%         if sets.fitRangeToCleanedDataMode
%             import Microscopy.cleanup_movie;
%             [cleanedDataArr, cleanupDetails] = cleanup_movie(movie3d);
%             nrmMinRawVal = min(cleanedDataArr(:));
%             nrmMaxRawVal = cleanupDetails.border.maxIncluded;
%             if(nrmMaxRawVal == nrmMinRawVal)
%                 nrmMaxRawVal = nrmMaxRawVal + 1;
%             end
%             rawValRange = [nrmMinRawVal, nrmMaxRawVal];
%         end
%             
%             
%         
%         % Detect all the molecules in the file, returned as cell of struct.
%         gsMovObj = get_grayscale_movie_obj(srcTiffFilepath);
%         import Microscopy.GrayscaleMovieStorageMode;
%         [~, grayscaleVideo] = gsMovObj.try_get_bounded_data(GrayscaleMovieStorageMode.Normalized);
% 
%         if (size(grayscaleVideo, 4) > 1) && (size(grayscaleVideo, 3) == 1)
%             grayscaleVideo = permute(grayscaleVideo, [1 2 4 3]);
%         end
        
        % detect molecules
%         import OldDBM.MoleculeDetection.detect_molecules;
%         [rotatedMovie, miniRotatedMoviesCoords, colCenterIdxs, rowEdgeIdxs] = detect_molecules(grayscaleVideo, settings);

%         miniRotatedMovies = cellfun(@(miniMovieCoords) rotatedMovie(...
%                 miniMovieCoords(1,1):miniMovieCoords(1,2),...
%                 miniMovieCoords(2,1):miniMovieCoords(2,2),...
%                 miniMovieCoords(3,1):miniMovieCoords(3,2)...
%             ), ...
%             miniRotatedMoviesCoords, ...
%             'UniformOutput', false);
%         
%         figure,imagesc(rotatedMovie(:,:,1))
%         hold on
%         idx =2
%         plot(miniRotatedMoviesCoords{idx}(2,1),miniRotatedMoviesCoords{idx}(1,1),'redx')
%         plot(miniRotatedMoviesCoords{idx}(2,2),miniRotatedMoviesCoords{idx}(1,2),'redx')
% 
%         import Fancy.Utils.merge_structs;
%         defaultOldMoleculeStruct = struct( ...
%                 'frames', [], ...
%                 'kymograph', [], ...
%                 'information', [], ...
%                 'passesFilters', true ...
%             );
%         rawFlatKymos = cellfun(...
%             @(miniRotatedMovie) ...
%                 permute(mean(miniRotatedMovie, 2), [3 1 2]), ...
%             miniRotatedMovies, ...
%             'UniformOutput', false);


    end



% 
%         function [gsMovObj] = get_grayscale_movie_obj(srcTiffFilepath)
%             import Fancy.AppMgr.ImportItemContext;
%             itemSelectionTime = clock();
%             [~, filenamSansExt, fileExt] = fileparts(srcTiffFilepath);
%             filename = [filenamSansExt, fileExt];
%             displayName = filename;
%             importItemContext = ImportItemContext(srcTiffFilepath, itemSelectionTime);
% 
% 
%             import Microscopy.Import.import_grayscale_tiff_video;
%             fprintf('::> Loading movie for %s...\n', displayName);
% 
%             import Microscopy.GrayscaleMovieFactory;
%             movieFactory = GrayscaleMovieFactory.get_instance();
%             [failMsg, gsMovObj] = movieFactory.load_grayscale_movie_from_tiff(sets.fitRangeToCleanedDataMode, importItemContext.ImportSrcPath);
%             if any(failMsg)
%                 fprintf(' Movie load failure: %s\n', failMsg);
%                 fprintf('<:: Failed loading movie for %s\n', displayName);
%             else
%                 fprintf('<:: Loaded movie for %s\n', displayName);
%             end
%         end
% 
%         fprintf('All file(s) imported and molecules detected\n');


end