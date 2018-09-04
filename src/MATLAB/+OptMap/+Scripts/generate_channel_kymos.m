function [allFlatChannelKymoDestPaths, movieProcessingResultSavepaths, srcTiffFilepaths] = generate_channel_kymos(forDotMovie)
    % GENERATE_CHANNEL_KYMOS - Prompts for tiff movie filepaths, processes 
    %   the movies to extract channel kymographs, and then saves the 
    %   resulting data and the flat kymograph images in a folder named
    %   after the movie file
    %
    % Inputs:
    %   forDotMovie (optional; defaults to false)
    %     logical which is true if the tiffs should be processed as movies
    %     of dot-labeled molecules as opposed to molecules stained through
    %     competitive binding
    %
    % Outputs:
    %   allFlatChannelKymoDestPaths
    %     cell array of filepaths for the flat kymograph images
    %   movieProcessingResultSavepaths
    %     cell array of filepaths for the mat files containing the movie
    %     processing results
    %   srcTiffFilepaths
    %     cell array of filepaths to tiff movies that were selected as
    %     sources 
    % 
    % Authors:
    %   Saair Quaderi 
    
    if nargin < 1
        forDotMovie = false;
    end
    if forDotMovie
        import OptMap.MovieKymoExtraction.process_dot_movie;
        process_movie = @process_dot_movie;
    else
        import OptMap.MovieKymoExtraction.process_cb_movie;
        process_movie = @process_cb_movie;
    end
    
    import Microscopy.Import.try_prompt_movie_filepaths;
    [~, srcTiffFilepaths] = try_prompt_movie_filepaths();
    numMovies = numel(srcTiffFilepaths);
    movieProcessingResultsStructs = cell(numMovies, 1);
    numFlatChannelKymos = zeros(numMovies, 1);
    for movieNum=1:numMovies
        srcTiffFilepath = srcTiffFilepaths{movieNum};
        [movieProcessingResultsStruct] = process_movie(srcTiffFilepath);
        movieProcessingResultsStructs{movieNum} = movieProcessingResultsStruct;
        numFlatChannelKymos(movieNum) = numel(movieProcessingResultsStruct.data.flat_kymo.channelKymos);
    end
   
    movieProcessingResultSavepaths = cell(numMovies, 1);
    
    totalNumChannelKymos = sum(numFlatChannelKymos);
    allFlatChannelKymos = cell(totalNumChannelKymos,1);
    allMovieChannelNums = zeros(totalNumChannelKymos,1);
    allFlatChannelKymoHashes = cell(totalNumChannelKymos,1);
    allFlatChannelDestDirpaths = cell(totalNumChannelKymos,1);
    if totalNumChannelKymos == 0
        return;
    end
    
    [srcTiffDirpath, movieFilenamesSansExt] = cellfun(@fileparts, srcTiffFilepaths(:), 'UniformOutput', false);
    movieResultsDirpaths = fullfile(srcTiffDirpath, movieFilenamesSansExt);
    lastFlatChannelKymoNum = 0;
    import Fancy.IO.mkdirp;
    import Fancy.Utils.data_hash;
    for movieNum=1:numMovies
        movieFilenameSansExt = movieFilenamesSansExt{movieNum};
        movieProcessingResultsStruct = movieProcessingResultsStructs{movieNum};
        if isempty(movieProcessingResultsStruct)
            continue;
        end
        movieResultsDirpath = movieResultsDirpaths{movieNum};
        mkdirp(movieResultsDirpath);
        movieProcessingResultSavepath = fullfile(movieResultsDirpath, strcat(movieFilenameSansExt, '_processing_results.mat'));
        movieProcessingResultSavepaths{movieNum} = movieProcessingResultSavepath;
        save(movieProcessingResultSavepath, '-struct', 'movieProcessingResultsStruct');
        numFlatChannelKymosInMovie = numFlatChannelKymos(movieNum);
        movieChannelNums = (1:numFlatChannelKymosInMovie);
        channelKymoNums = lastFlatChannelKymoNum + movieChannelNums;
        allMovieChannelNums(channelKymoNums) = movieChannelNums;
        allFlatChannelDestDirpaths(channelKymoNums) = {movieResultsDirpath};
        flatChannelKymos = movieProcessingResultsStruct.data.flat_kymo.channelKymos(:);
        allFlatChannelKymos(channelKymoNums) = flatChannelKymos;
        allFlatChannelKymoHashes(channelKymoNums) = cellfun(@data_hash, flatChannelKymos, 'UniformOutput', false);
        lastFlatChannelKymoNum = channelKymoNums(end);
    end
    
    allMovieChannelNumStrs = arrayfun(@num2str, allMovieChannelNums, 'UniformOutput', false);
    allFlatChannelKymoDestPaths = cellfun(...
        @(fDirpath, mChannelNumStr, channelKymoHash)...
            fullfile(fDirpath, strcat('flatChannelKymo_', mChannelNumStr, '_', channelKymoHash, '.tif')),...
        allFlatChannelDestDirpaths,...
        allMovieChannelNumStrs,...
        allFlatChannelKymoHashes,...
        'UniformOutput', false);
    
    import Fancy.UI.ProgressFeedback.BasicTextProgressMessenger;
    progress_messenger = BasicTextProgressMessenger.get_instance();
    progress_messenger.init(sprintf(' Saving channel kymos...\n'));
    for channelKymoNum=1:totalNumChannelKymos
        imwrite(allFlatChannelKymos{channelKymoNum}, allFlatChannelKymoDestPaths{channelKymoNum});
        progress_messenger.checkin(channelKymoNum, totalNumChannelKymos);
    end
    msgOnCompletion = sprintf('    Saved kymos\n');
    progress_messenger.finalize(msgOnCompletion);
end