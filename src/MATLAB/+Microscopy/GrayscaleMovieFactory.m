classdef (Sealed) GrayscaleMovieFactory < handle
    % GRAYSCALEMOVIEFACTORY - Makes GrayscaleMovie objects
    %
    % Note: An instance of GRAYSCALEMOVIEFACTORY should be retrieved
    %   using get_instance since it will be defined as a persistent
    %   variable using the singleton design pattern.
    %
    % http://mathworks.com/help/matlab/ref/persistent.html
    % http://mathworks.com/help/matlab/matlab_oop/controlling-the-number-of-instances.html
    %
    % Authors:
    %   Saair Quaderi
    
    properties (Constant)
        Version = [0, 0, 1];
        
        DefaultFitRangeToCleanedDataMode = true;
        DefaultKeepMovieObjsSlim = true;
        DefaultStorageMode = Microscopy.GrayscaleMovieStorageMode.get_default_storage_mode();
        DefaultDefaultTiffDirpath = Fancy.AppMgr.AppResourceMgr.get_app_dirpath();
        DefaultAutoUpdateDefaultTiffDirpath = true;
    end
    properties (SetAccess = private)
        FitRangeToCleanedDataMode = Microscopy.GrayscaleMovieFactory.DefaultFitRangeToCleanedDataMode;
        KeepMovieObjsSlim = Microscopy.GrayscaleMovieFactory.DefaultKeepMovieObjsSlim;
        StorageMode = Microscopy.GrayscaleMovieFactory.DefaultStorageMode;
        DefaultTiffDirpath = Microscopy.GrayscaleMovieFactory.DefaultDefaultTiffDirpath;
        AutoUpdateDefaultTiffDirpath = Microscopy.GrayscaleMovieFactory.DefaultAutoUpdateDefaultTiffDirpath;
    end
    
    methods (Access = private)
        function [gsMovF] = GrayscaleMovieFactory()
            % GRAYSCALEMOVIEFACTORY - Constructor, purposefully made
            % private to follow Singleton design pattern:
            %
            % http://mathworks.com/help/matlab/matlab_oop/controlling-the-number-of-instances.html
            %
            % Use get_instance publicly
        end
    end
    
    methods (Static)
        function [singletonGsMovF] = get_instance()
            % GET_INSTANCE - retrieves the single instance of this data
            %   manager
            %
            % Outputs:
            %   singletonGsMovF
            %     the instance of the grayscale movie factory
            %
            % Side-effects:
            %   Creates the local grayscale movie factory if it does not
            %   already exist
            %
            % Authors:
            %   Saair Quaderi
         
            % Part of the Singleton design pattern:
            % http://mathworks.com/help/matlab/matlab_oop/controlling-the-number-of-instances.html
            persistent localPersisentGsMovF;
            if isempty(localPersisentGsMovF) || not(isvalid(localPersisentGsMovF))
                localPersisentGsMovF = Microscopy.GrayscaleMovieFactory();
            end
            singletonGsMovF = localPersisentGsMovF;
        end
    end
    
    methods
        function [] = set_future_storage_mode(gsMovF, storageMode)
            validateattributes(storageMode, {'Microscopy.GrayscaleMovieStorageMode'}, {'scalar'}, 2);
            gsMovF.StorageMode = storageMode;
        end
        function [] = enable_future_slim_maintenance(gsMovF)
            gsMovF.KeepMovieObjsSlim = true;
        end
        function [] = disable_future_slim_maintenance(gsMovF)
            gsMovF.KeepMovieObjsSlim = false;
        end
        
        function [failMsg, gsMovObj] = load_grayscale_movie_from_tiff(gsMovF, fitRangeToCleanedDataMode, srcTiffFilepath)
            if nargin < 2
                fitRangeToCleanedDataMode =  gsMovF.FitRangeToCleanedDataMode;
            end
            if nargin < 3
                srcTiffFilepath = [];
            end
            if isempty(srcTiffFilepath)
                [aborted, srcTiffFilepath] = gsMovF.prompt_single_tiff();
            else
                aborted = false;
            end
            failMsg = false;
            if aborted || isempty(srcTiffFilepath)
                gsMovObj = [];
                failMsg = 'No tiff file was specified to make the movie from';
                return;
            end
            keepMovieObjSlim = gsMovF.KeepMovieObjsSlim;
            storageMode = gsMovF.StorageMode;
            
            
            import Microscopy.Import.import_single_unbroken_tiff_vid_segment;
            [rawDataArr, rawValRange, gsMovC] = import_single_unbroken_tiff_vid_segment(srcTiffFilepath);

            
%             fitRangeToCleanedDataMode = 0; % TODO: make this work for single frame with 1
            if fitRangeToCleanedDataMode
                import Microscopy.cleanup_movie;
                [cleanedDataArr, cleanupDetails] = cleanup_movie(permute(rawDataArr, [1 2 4 3]));
                nrmMinRawVal = min(cleanedDataArr(:));
                nrmMaxRawVal = cleanupDetails.border.maxIncluded;
                if(nrmMaxRawVal == nrmMinRawVal)
                    nrmMaxRawVal = nrmMaxRawVal + 1;
                end
                rawValRange = [nrmMinRawVal, nrmMaxRawVal];
            end
            
            import Microscopy.GrayscaleMovie;
            gsMovObj = GrayscaleMovie(gsMovC, rawDataArr, rawValRange);
            if storageMode.is_normalized_mode()
                gsMovObj.normalize_storage();
            end
            if keepMovieObjSlim
                gsMovObj.enable_stay_slim();
            end
        end
    end
    methods (Access = private)

        function [aborted, srcTiffFilepath] = prompt_single_tiff(gsMovF)
            defaultTiffDirpath = gsMovF.DefaultTiffDirpath;
            autoUpdateDefaultTiffDirpath = gsMovF.AutoUpdateDefaultTiffDirpath;
            import Microscopy.Import.try_prompt_movie_filepaths;
            [aborted, srcTiffFilepaths] = try_prompt_movie_filepaths([], false, defaultTiffDirpath);
            if aborted
                srcTiffFilepath = '';
            else
                srcTiffFilepath = srcTiffFilepaths{1};
                if autoUpdateDefaultTiffDirpath
                    [defaultTiffDirpath, ~, ~] = fileparts(srcTiffFilepath);
                    gsMovF.DefaultTiffDirpath = defaultTiffDirpath;
                end
            end
        end
    end
    
end

